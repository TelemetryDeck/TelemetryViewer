//
//  OrganizationAdmin.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 07.12.20.
//

import SwiftUI

struct InsightQueryDetailView: View {
    let entry: InsightDTO

    var body: some View {
        ScrollView {
            CustomSection(header: Text("Insight"), summary: EmptyView(), footer: EmptyView()) {
                Text(entry.title)
                if let lastRunAt = entry.lastRunAt { Text(lastRunAt, style: .date) } else { Text("never") }
                if let lastRunTime = entry.lastRunTime { Text("\(lastRunTime)s") } else { Text("–") }
            }

            CustomSection(header: Text("ID"), summary: EmptyView(), footer: EmptyView()) {
                Text(entry.id.uuidString)

                Button("Copy to Clipboard") {
                    saveToClipBoard(entry.id.uuidString)
                }
                .buttonStyle(SmallSecondaryButtonStyle())
            }

            if let lastQuery = entry.lastQuery {
                CustomSection(header: Text("Query"), summary: EmptyView(), footer: EmptyView()) {
                    Text(lastQuery).font(.system(size: 10, design: .monospaced))

                    Button("Copy to Clipboard") {
                        saveToClipBoard(lastQuery)
                    }
                    .buttonStyle(SmallSecondaryButtonStyle())
                }
            }
        }
        .padding()
    }
}

struct InsightQueryAdmin: View {
    @EnvironmentObject var api: APIRepresentative
    @State private var selectedInsight: InsightCalculationResult?
    @State private var sidebarShown: Bool = false
    @State private var isLoading: Bool = false

    let refreshTimer = Timer.publish(
        every: 1 * 60, // 1 minute
        on: .main,
        in: .common
    ).autoconnect()

    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return formatter
    }()

    var padding: CGFloat? {
        #if os(macOS)
            return nil
        #else
            return 0
        #endif
    }

    #if os(iOS)
        @Environment(\.horizontalSizeClass) var sizeClass
    #endif

    var body: some View {
        AdaptiveStack(spacing: 0) {
            List {
                if isLoading {
                    ProgressView()
                }

                HStack {
                    if let aggregate = api.insightQueryAdminAggregate {
                        ValueUnitAndTitleView(value: aggregate.min, title: "min", unit: "s")
                        Divider()
                        ValueUnitAndTitleView(value: aggregate.avg, title: "avg", unit: "s")
                        Divider()
                        ValueUnitAndTitleView(value: aggregate.max, title: "max", unit: "s")
                    } else {
                        Text("...")
                    }
                }

                ForEach(api.insightQueryAdminListEntries) { entry in
                    NavigationLink(destination: InsightQueryDetailView(entry: entry)) {
                        HStack {
                            Text(entry.title)
                            Spacer()
                            if let lastRunAt = entry.lastRunAt { Text(lastRunAt, style: .date) } else { Text("never") }
                            if let lastRunTime = entry.lastRunTime { Text("\(lastRunTime)s") } else { Text("–") }
                        }
                    }
                }
            }
        }
        .navigationTitle("Insight Query Admin")
        .onAppear {
            isLoading = true
            api.getInsightQueryAdminAggregates()
            api.getInsightQueryAdminListEntries { _ in
                self.isLoading = false
            }
        }
        .onReceive(refreshTimer) { _ in
            isLoading = true
            api.getInsightQueryAdminAggregates()
            api.getInsightQueryAdminListEntries { _ in
                self.isLoading = false
            }
        }
    }
}
