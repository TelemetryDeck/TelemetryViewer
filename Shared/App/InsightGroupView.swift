//
//  InsightGroupView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 17.02.21.
//

import SwiftUI

struct InsightGroupView: View {
    @EnvironmentObject var api: APIRepresentative
    @State private var selectedInsightID: UUID?
    @State private var isDefaultItemActive = true

    let app: TelemetryApp
    let insightGroupID: UUID

    var insightGroup: InsightGroup? {
        api.insightGroups[app]?.first { $0.id == insightGroupID }
    }

    var body: some View {
        ScrollView(.vertical) {
            if let insightGroup = insightGroup {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 800), spacing: 0)], alignment: .leading, spacing: 0) {
                    let expandedInsights = insightGroup.insights.filter { $0.isExpanded }.sorted(by: { $0.order ?? 0 < $1.order ?? 0 })
                    let nonExpandedInsights = insightGroup.insights.filter { !$0.isExpanded }.sorted(by: { $0.order ?? 0 < $1.order ?? 0 })

                    ForEach(expandedInsights) { insight in

                        #if os(iOS)
                            let destination = NewInsightEditor(app: app, insightGroup: insightGroup, insight: insight)
                        #else
                            let destination = InsightSidebarView(app: app, insightGroup: insightGroup, insight: insight)
                        #endif

                        NavigationLink(destination: destination, tag: insight.id, selection: $selectedInsightID) {
                            InsightView(topSelectedInsightID: $selectedInsightID, app: app, insightGroup: insightGroup, insight: insight)
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            #if os(macOS)
                                expandRightSidebar()
                            #endif
                        })
                        .buttonStyle(CardButtonStyle(isSelected: selectedInsightID == insight.id))
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 0)], alignment: .leading, spacing: 0) {
                        ForEach(nonExpandedInsights) { insight in

                            #if os(iOS)
                                let destination = NewInsightEditor(app: app, insightGroup: insightGroup, insight: insight)
                            #else
                                let destination = InsightSidebarView(app: app, insightGroup: insightGroup, insight: insight)
                            #endif

                            NavigationLink(destination: destination, tag: insight.id, selection: $selectedInsightID) {
                                InsightView(topSelectedInsightID: $selectedInsightID, app: app, insightGroup: insightGroup, insight: insight)
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                #if os(macOS)
                                    expandRightSidebar()
                                #endif
                            })
                            .buttonStyle(CardButtonStyle(isSelected: selectedInsightID == insight.id))
                        }
                    }
                }
            } else {
                Text("Loading InsightGroup...")
            }

            #if os(macOS)
                NavigationLink(
                    destination: InsightSidebarView(app: app, insightGroup: insightGroup, insight: nil),
                    isActive: $isDefaultItemActive,
                    label: {
                        EmptyView()
                    }
                ).opacity(0)
            #endif
        }
        .background(Color.cardBackground)
        .onTapGesture {
            selectedInsightID = nil
            isDefaultItemActive = true
        }
    }
}
