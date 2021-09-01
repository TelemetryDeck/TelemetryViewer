//
//  InsightGroupView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 17.02.21.
//

import SwiftUI

struct InsightGroupView: View {
    @EnvironmentObject var insightService: OldInsightService
    @State private var selectedInsightID: UUID?
    @State private var insightEditorContent: InsightEditorContent?

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
        ZStack(alignment: .bottomLeading) {
                ScrollView(.vertical) {
                    if let insightGroup = insightGroup {
                        if insightGroup.insights.count == 0 {
                            EmptyInsightGroupView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        } else {
                            insightsGrid(insightGroup: insightGroup)
                                .padding(.bottom, 50)
                        }
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .padding()
                    }
                }
                .frame(idealWidth: 600)
                .onTapGesture {
                    selectedInsightID = nil
                    insightEditorContent = nil
                }

                if let selectedInsightID = selectedInsightID, let insightEditorContent = insightEditorContent {
                    InsightEditor(editorContent: insightEditorContent, appID: appID, insightGroupID: insightGroupID)
                        .tag(selectedInsightID)
                } else {
                    Text("Insights are your view into Telemetry's database. Select one to edit it live, or click the plus button in the toolbar to create a new insight.")
                        .font(.footnote)
                        .foregroundColor(.grayColor)
                        .padding()
                }



            bottomHelpView
        }
    }

    func editor(for insight: DTO.InsightDTO) -> some View {
        let editorContent = InsightEditorContent.from(insight: insight)
        return InsightEditor(editorContent: editorContent, appID: appID, insightGroupID: insightGroupID)
    }

    func card(for insight: DTO.InsightDTO, insightGroup: DTO.InsightGroup) -> some View {
        return Button {
            selectedInsightID = insight.id
            insightEditorContent = nil
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                withAnimation(.easeOut(duration: 0.3)) {
                    insightEditorContent = InsightEditorContent.from(insight: insight)
                }
            }
        } label: {
            InsightView(topSelectedInsightID: $selectedInsightID, appID: appID, insightGroupID: insightGroup.id, insightID: insight.id)
        }
        .buttonStyle(CardButtonStyle(isSelected: selectedInsightID == insight.id))
        #if os(macOS)
            .contextMenu {
                Button("Delete") {
                    insightService.delete(insightID: insight.id, in: insightGroup.id, in: appID)
                }
            }
        #endif
    }

    func insightsGrid(insightGroup: DTO.InsightGroup) -> some View {
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
    }

    var bottomHelpView: some View {
        VStack {
            Divider()

            AdaptiveStack {
                if let insightGroup = insightGroup {
                    NavigationLink("Edit Group", destination: OldInsightGroupEditor(appID: appID, insightGroup: insightGroup), tag: insightGroup.id, selection: $selectedInsightID)
                        .buttonStyle(SmallSecondaryButtonStyle())
                        .frame(maxWidth: 400)
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
            }
            .padding(.bottom, 8)
            .padding(.horizontal)
        }
        .background(Color.cardBackground)
    }
}
