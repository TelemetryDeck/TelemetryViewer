//
//  GroupView.swift
//  GroupView
//
//  Created by Daniel Jilg on 18.08.21.
//

import SwiftUI
import TelemetryClient

let spacing: CGFloat = 0.5

struct GroupView: View {
    let groupID: DTOv2.Group.ID

    @Binding var selectedInsightID: DTOv2.Insight.ID?
    @Binding var sidebarVisible: Bool

    @EnvironmentObject var groupService: GroupService
    @EnvironmentObject var insightService: InsightService
    @EnvironmentObject var lexiconService: LexiconService

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
                InsightsList(groupID: groupID, isSelectable: false, selectedInsightID: $selectedInsightID, sidebarVisible: $sidebarVisible)
            }
            .frame(idealWidth: 600, maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture {
                selectedInsightID = nil
            }
        }
        .onAppear {
            TelemetryManager.send("GroupViewAppear")
        }
    }
}
