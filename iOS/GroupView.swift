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
    case middle = 0.9, low = 0.5, bottom = 0.17
}

struct GroupView: View {
    let groupID: DTOv2.Group.ID

    @Binding var selectedInsightID: DTOv2.Insight.ID?
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

    func helpMessage() -> String {
        if bottomSheetPosition == .bottom {
            return "Swipe up to edit Groups and Insights"
        } else {
            if selectedInsightID == nil {
                return "Select an Insight to edit it instead of the group"
            } else {
                return "Swipe down to save"
            }
        }
    }

    var body: some View {
        AdaptiveStack(spacing: 0) {
            ScrollView(.vertical) {
                InsightsList(groupID: groupID, isSelectable: bottomSheetPosition != .bottom, selectedInsightID: $selectedInsightID, sidebarVisible: $sidebarVisible)
            }
            .frame(idealWidth: 600, maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture {
                selectedInsightID = nil
            }
            .onChange(of: bottomSheetPosition) { _ in
                if bottomSheetPosition == .bottom {
                    selectedInsightID = nil
                }
            }
            .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition, options: [.allowContentDrag, .swipeToDismiss], headerContent: {
                VStack {
                    Text(helpMessage())
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.subheadline).foregroundColor(.secondary)
                        .padding()
                    Divider()
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
                .padding(.top)
            }
        }
        .onAppear {
            TelemetryManager.send("GroupViewAppear")
        }
    }
}
