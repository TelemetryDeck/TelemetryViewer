//
//  InsightGroupView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 17.02.21.
//

import SwiftUI
import TelemetryModels

struct InsightGroupView: View {
    @EnvironmentObject var api: APIRepresentative
    @State private var selectedInsightID: UUID?
    @State private var isDefaultItemActive = true
    
    let appID: UUID
    let insightGroupID: UUID
    
    var app: TelemetryApp? { api.app(with: appID) }
    var insightGroup: InsightGroup? {
        guard let app = app else { return nil }
        return api.insightGroups[app]?.first { $0.id == insightGroupID }
    }
    
    #if os(iOS)
    let spacing: CGFloat = 0.5
    #else
    let spacing: CGFloat = 1
    #endif
    
    var body: some View {
        ScrollView(.vertical) {
            if let insightGroup = insightGroup {
                if insightGroup.insights.count == 0 {
                    EmptyInsightGroupView(selectedInsightGroupID: insightGroup.id, appID: appID)
                        .frame(maxWidth: 400)
                        .padding(.horizontal)
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 800), spacing: spacing)], alignment: .leading, spacing: spacing) {
                        let expandedInsights = insightGroup.insights.filter { $0.isExpanded }.sorted(by: { $0.order ?? 0 < $1.order ?? 0 })
                        let nonExpandedInsights = insightGroup.insights.filter { !$0.isExpanded }.sorted(by: { $0.order ?? 0 < $1.order ?? 0 })

                        ForEach(expandedInsights) { insight in
                            if let app = app {
                                let destination = InsightEditor(appID: appID, insightGroupID: insightGroupID, insightID: insight.id)

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

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: spacing)], alignment: .leading, spacing: spacing) {
                            ForEach(nonExpandedInsights) { insight in
                                if let app = app {
                                    let destination = InsightEditor(appID: appID, insightGroupID: insightGroupID, insightID: insight.id)

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
                    .padding(.vertical, spacing)
                    .background(Color.separatorColor)
                }
            } else {
                Text("Loading InsightGroup...")
            }

            AdaptiveStack {
                if let insightGroup = insightGroup, let app = app {
                    NavigationLink("Edit Group", destination: InsightGroupEditor(app: app, insightGroup: insightGroup))
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
