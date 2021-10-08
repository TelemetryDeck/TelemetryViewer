//
//  GroupView.swift
//  GroupView
//
//  Created by Daniel Jilg on 18.08.21.
//

import SwiftUI
import TelemetryClient

let spacing: CGFloat = 1

struct GroupView: View {
    let groupID: DTOv2.Group.ID

    @Binding var selectedInsightID: DTOv2.Insight.ID?
    @Binding var sidebarVisible: Bool

    @EnvironmentObject var groupService: GroupService
    @EnvironmentObject var insightService: InsightService
    @EnvironmentObject var lexiconService: LexiconService
    
    var editorPanelEdge: Edge {
        return .trailing
    }

    var body: some View {
        AdaptiveStack(spacing: 0) {
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
                .transition(.move(edge: editorPanelEdge))
                .onChange(of: groupID) { _ in
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
                    InsightsGrid(selectedInsightID: $selectedInsightID, sidebarVisible: $sidebarVisible, insightGroup: insightGroup, showBottomSondrine: false, isSelectable: true)
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

    var loadingStateIndicator: some View {
        LoadingStateIndicator(loadingState: groupService.loadingState(for: groupID), title: groupService.group(withID: groupID)?.title)
    }
}
