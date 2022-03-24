//
//  InsightsList.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 24.09.21.
//

import SwiftUI
import DataTransferObjects


struct InsightsList: View {
    let groupID: DTOv2.Group.ID
    let isSelectable: Bool
    
    @Binding var selectedInsightID: DTOv2.Insight.ID?
    @Binding var sidebarVisible: Bool
    @EnvironmentObject var groupService: GroupService
    
    var body: some View {
        Group {
            if let insightGroup = groupService.group(withID: groupID) {
                if !insightGroup.insightIDs.isEmpty {
                    InsightsGrid(selectedInsightID: $selectedInsightID, sidebarVisible: $sidebarVisible, insightGroup: insightGroup, isSelectable: isSelectable)
                } else {
                    EmptyInsightGroupView()
                        .frame(maxWidth: 400)
                        .padding()
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
