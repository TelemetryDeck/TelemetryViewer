//
//  GroupView.swift
//  GroupView
//
//  Created by Daniel Jilg on 18.08.21.
//

import BottomSheet
import SwiftUI
import TelemetryClient

let spacing: CGFloat = 0.5

enum EditorBottomSheetPosition: CGFloat, CaseIterable {
    case middle = 0.7, bottom = 0.125
}

struct GroupView: View {
    let groupID: DTOsWithIdentifiers.Group.ID

    @Binding var selectedInsightID: DTOsWithIdentifiers.Insight.ID?
    @Binding var sidebarVisible: Bool

    @EnvironmentObject var groupService: GroupService
    @EnvironmentObject var insightService: InsightService
    @EnvironmentObject var lexiconService: LexiconService

    @State private var bottomSheetPosition: EditorBottomSheetPosition = .bottom

    @Environment(\.horizontalSizeClass) var sizeClass

    var editorPanelEdge: Edge {
        if sizeClass == .compact {
            return .bottom
        } else {
            return .trailing
        }
    }

    var body: some View {
        AdaptiveStack(spacing: 0) {
            ScrollView(.vertical) {
                InsightsList(groupID: groupID, selectedInsightID: $selectedInsightID, sidebarVisible: $sidebarVisible)
            }
            .frame(idealWidth: 600, maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture {
                selectedInsightID = nil
            }
            .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition, options: [.allowContentDrag, .swipeToDismiss, .tapToDissmiss], headerContent: {
                VStack(alignment: .leading) {
                    Group {
                        switch bottomSheetPosition {
                        case .middle:
                            Text("Select an Insight to edit it")
                        case .bottom:
                            Text("Swipe up to edit Groups and Insights")
                        }
                    }

                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.subheadline).foregroundColor(.secondary)
                }
            }) {
                VStack(spacing: 0) {
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
                .padding([.horizontal, .top])
            }
        }
        .onAppear {
            TelemetryManager.send("GroupViewAppear")
        }
    }
}
