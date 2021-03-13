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
                if insightGroup.insights.count == 0 {
                    EmptyInsightGroupView(selectedInsightGroupID: insightGroup.id, appID: app.id)
                        .frame(maxWidth: 400)
                        .padding(.horizontal)
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 800), spacing: 0)], alignment: .leading, spacing: 0) {
                        let expandedInsights = insightGroup.insights.filter { $0.isExpanded }.sorted(by: { $0.order ?? 0 < $1.order ?? 0 })
                        let nonExpandedInsights = insightGroup.insights.filter { !$0.isExpanded }.sorted(by: { $0.order ?? 0 < $1.order ?? 0 })

                        ForEach(expandedInsights) { insight in
                            let destination = NewInsightEditor(app: app, insightGroup: insightGroup, insight: insight)

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
                                let destination = NewInsightEditor(app: app, insightGroup: insightGroup, insight: insight)

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
                }
            } else {
                Text("Loading InsightGroup...")
            }

            AdaptiveStack {
                if let insightGroup = insightGroup {
                    NavigationLink("Edit Group", destination: NewInsightGroupEditor(app: app, insightGroup: insightGroup))
                        .buttonStyle(SmallSecondaryButtonStyle())
                        .frame(maxWidth: 400)
                        .padding()
                        .simultaneousGesture(TapGesture().onEnded {
                            #if os(macOS)
                                expandRightSidebar()
                            #endif
                        })
                }

                Button("Documentation: Sending Signals") {
                    #if os(macOS)
                        NSWorkspace.shared.open(URL(string: "https://apptelemetry.io/pages/quickstart.html")!)
                    #else
                        UIApplication.shared.open(URL(string: "https://apptelemetry.io/pages/quickstart.html")!)
                    #endif
                }
                .buttonStyle(SmallSecondaryButtonStyle())
                .frame(maxWidth: 400)
                .padding()
            }
        }
        .background(Color.cardBackground)
        .onTapGesture {
            selectedInsightID = nil
            isDefaultItemActive = true
        }
    }
}
