//
//  GroupView.swift
//  GroupView
//
//  Created by Daniel Jilg on 18.08.21.
//

import SwiftUI
import TelemetryClient

#if os(iOS)
let spacing: CGFloat = 0.5
#else
let spacing: CGFloat = 1
#endif

struct GroupView: View {
    let groupID: DTOsWithIdentifiers.Group.ID

    @Binding var selectedInsightID: DTOsWithIdentifiers.Insight.ID?
    @Binding var sidebarVisible: Bool

    @EnvironmentObject var groupService: GroupService
    @EnvironmentObject var insightService: InsightService
    @EnvironmentObject var lexiconService: LexiconService

    var body: some View {
        HStack(spacing: 0) {
            ScrollView(.vertical) {
                insightsList
            }
            .frame(idealWidth: 600, maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture {
                selectedInsightID = nil
            }

            if sidebarVisible {
                Divider()
                Group {
                    if let selectedInsightID = selectedInsightID {
                        if let insight = insightService.insight(withID: selectedInsightID), let group = groupService.group(withID: groupID) {
                            EditorView(viewModel: EditorViewModel(insight: insight, appID: group.appID, insightService: insightService, groupService: groupService, lexiconService: lexiconService), selectedInsightID: $selectedInsightID)
                        } else {
                            IconOnlyLoadingStateIndicator(loadingState: insightService.loadingState(for: selectedInsightID))
                        }

                    } else if let group = groupService.group(withID: groupID) {
                        InsightGroupEditor(groupID: groupID, appID: group.appID, title: group.title, order: group.order ?? 0)
                    } else {
                        Text("Please select a thing!")
                    }
                }
                .frame(maxWidth: 250, maxHeight: .infinity)
                .transition(.move(edge: .trailing))
                .onChange(of: groupID) { newValue in
                    sidebarVisible = false
                }
            }
        }
        .onAppear {
            TelemetryManager.send("GroupViewAppear")
        }
    }

    var insightsList: some View {
        Group {
            if let insightGroup = groupService.group(withID: groupID) {
                if !insightGroup.insightIDs.isEmpty {
                    insightsGrid(withGroup: insightGroup)
                } else {
                    EmptyInsightGroupView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }

            } else {
                loadingStateIndicator
            }
        }
        .padding(.vertical, spacing)
    }

    func insightsGrid(withGroup insightGroup: DTOsWithIdentifiers.Group) -> some View {
        let allInsights = insightGroup.insightIDs.map {
            ($0, insightService.insight(withID: $0))
        }

        let loadedInsights = allInsights.filter { $0.1 != nil }
        let loadingInsights = allInsights.filter { $0.1 == nil }
        let expandedInsights = loadedInsights.filter { $0.1?.isExpanded == true }.sorted { $0.1?.order ?? 0 < $1.1?.order ?? 0 }
        let unexpandedInsights = loadedInsights.filter { $0.1?.isExpanded == false }.sorted { $0.1?.order ?? 0 < $1.1?.order ?? 0 }

        return LazyVGrid(columns: [GridItem(.adaptive(minimum: 800), spacing: spacing)], alignment: .leading, spacing: spacing) {
            ForEach(expandedInsights.map { $0.0 }, id: \.self) { insightID in
                InsightCard(selectedInsightID: $selectedInsightID, sidebarVisible: $sidebarVisible, insightID: insightID)
                    .id(insightID)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: spacing)], alignment: .leading, spacing: spacing) {
                ForEach(unexpandedInsights.map { $0.0 }, id: \.self) { insightID in
                    InsightCard(selectedInsightID: $selectedInsightID, sidebarVisible: $sidebarVisible, insightID: insightID)
                        .id(insightID)
                }
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: spacing)], alignment: .leading, spacing: spacing) {
                ForEach(loadingInsights.map { $0.0 }, id: \.self) { insightID in
                    InsightCard(selectedInsightID: $selectedInsightID, sidebarVisible: $sidebarVisible, insightID: insightID)
                        .id(insightID)
                }
            }
        }
    }

    var loadingStateIndicator: some View {
        LoadingStateIndicator(loadingState: groupService.loadingState(for: groupID), title: groupService.group(withID: groupID)?.title)
    }
}
