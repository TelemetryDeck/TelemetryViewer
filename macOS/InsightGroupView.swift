//
//  InsightGroupView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 17.02.21.
//

import SwiftUI

struct InsightGroupView: View {
    @EnvironmentObject var insightService: InsightService
    @State private var selectedInsightID: UUID?
    @State private var isDefaultItemActive = true

    let appID: UUID
    let insightGroupID: UUID

    var insightGroup: DTO.InsightGroup? {
        insightService.insightGroup(id: insightGroupID, in: appID)
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
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 800), spacing: spacing)], alignment: .leading, spacing: spacing) {
                        let expandedInsights = insightGroup.insights.filter { $0.isExpanded }.sorted(by: { $0.order ?? 0 < $1.order ?? 0 })
                        let nonExpandedInsights = insightGroup.insights.filter { !$0.isExpanded }.sorted(by: { $0.order ?? 0 < $1.order ?? 0 })

                        ForEach(expandedInsights) { insight in
                            card(for: insight, insightGroup: insightGroup)
                        }

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: spacing)], alignment: .leading, spacing: spacing) {
                            ForEach(nonExpandedInsights) { insight in
                                card(for: insight, insightGroup: insightGroup)
                            }
                        }
                    }
                    .padding(.vertical, spacing)
                    .background(Color.separatorColor)
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }

            AdaptiveStack {
                if let insightGroup = insightGroup {
                    NavigationLink("Edit Group", destination: InsightGroupEditor(appID: appID, insightGroup: insightGroup))
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

                #if os(iOS)
                NavigationLink("Recent Signals", destination: SignalList(appID: appID))
                    .buttonStyle(SmallSecondaryButtonStyle())
                    .padding()
                NavigationLink("Lexicon", destination: LexiconView(appID: appID))
                    .buttonStyle(SmallSecondaryButtonStyle())
                    .padding()
                #endif
            }
        }
        .background(Color.cardBackground)
        .onTapGesture {
            selectedInsightID = nil
            isDefaultItemActive = true
        }
    }
    
    func card(for insight: DTO.InsightDTO, insightGroup: DTO.InsightGroup) -> some View {
        let editorContent = InsightEditorContent.from(insight: insight)
        let destination = InsightEditor(editorContent: editorContent, appID: appID, insightGroupID: insightGroupID)

        return NavigationLink(destination: destination, tag: insight.id, selection: $selectedInsightID) {
            InsightView(topSelectedInsightID: $selectedInsightID, appID: appID, insightGroupID: insightGroup.id, insightID: insight.id)
        }
        .simultaneousGesture(TapGesture().onEnded {
            #if os(macOS)
            expandRightSidebar()
            #endif
        })
        .buttonStyle(CardButtonStyle(isSelected: selectedInsightID == insight.id))
    }
}
