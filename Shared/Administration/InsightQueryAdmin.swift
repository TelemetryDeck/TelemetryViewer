//
//  OrganizationAdmin.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 07.12.20.
//

import SwiftUI

struct InsightQueryAdmin: View {
    @EnvironmentObject var api: APIRepresentative
    @State private var selectedInsight: Insight?
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

    var DefaultSidebarWidth: CGFloat {
        #if os(iOS)
        if sizeClass == .compact {
            return 800
        } else {
            return 350
        }
        #else
        return 280
        #endif
    }

    var DefaultMoveTransition: AnyTransition {
        #if os(iOS)
        if sizeClass == .compact {
            return .move(edge: .bottom)
        } else {
            return .move(edge: .trailing)
        }

        #else
        return .move(edge: .trailing)
        #endif
    }
    
    var body: some View {
        AdaptiveStack(spacing: 0) {
            List {
                if isLoading {
                    ProgressView()
                }

                ForEach(api.insightQueryAdminListEntries) { entry in
                    ListItemView(selected: selectedInsight?.id == entry.id) {
                        Text(entry.title)
                        Spacer()
                        if let lastRunAt = entry.lastRunAt { Text(lastRunAt, style: .date) } else { Text("never") }
                        if let lastRunTime = entry.lastRunTime { Text("\(lastRunTime)s") } else { Text("–") }
                    }
                    .onTapGesture {
                        selectedInsight = entry
                        withAnimation {
                            sidebarShown = true
                        }
                    }
                }
            }

            if sidebarShown {
                if let entry = selectedInsight {
                    DetailSidebar(isOpen: $sidebarShown , maxWidth: DefaultSidebarWidth) {

                        VStack {
                            ScrollView {

                                CustomSection(header: Text("Insight"), summary: EmptyView(), footer: EmptyView()) {
                                    Text(entry.title)
                                    if let lastRunAt = entry.lastRunAt { Text(lastRunAt, style: .date) } else { Text("never") }
                                    if let lastRunTime = entry.lastRunTime { Text("\(lastRunTime)s") } else { Text("–") }
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
                        }
                        .padding(.horizontal, padding)
                    }

                    .transition(DefaultMoveTransition)
                }

            }
        }
        .navigationTitle("Insight Query Admin")
        .onAppear() {
            isLoading = true
            api.getInsightQueryAdminListEntries() { _ in
                self.isLoading = false
            }
        }
        .onReceive(refreshTimer) { _ in
            api.getInsightQueryAdminListEntries()
        }
    }
}