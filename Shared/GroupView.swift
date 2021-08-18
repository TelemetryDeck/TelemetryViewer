//
//  GroupView.swift
//  GroupView
//
//  Created by Daniel Jilg on 18.08.21.
//

import SwiftUI

#if os(iOS)
let spacing: CGFloat = 0.5
#else
let spacing: CGFloat = 1
#endif

struct GroupView: View {
    let groupID: DTOsWithIdentifiers.Group.ID
    
    @State var selectedInsightID: DTOsWithIdentifiers.Insight.ID?

    @Binding var sidebarVisible: Bool

    @EnvironmentObject var groupService: GroupService
    @EnvironmentObject var insightService: InsightService

    var body: some View {
        HSplitView {
            ScrollView(.vertical) {
            insightsList
            }
            .frame(idealWidth: 600, maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture {
                    selectedInsightID = nil
                }

            if sidebarVisible {
                Text("Hello Sidebar")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.move(edge: .trailing))
            }
        }
    }

    var insightsList: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: spacing)], alignment: .leading, spacing: spacing) {
            if let insightGroup = groupService.group(withID: groupID) {
                ForEach(insightGroup.insightIDs, id: \.self) { insightID in
                    InsightCard(selectedInsightID: $selectedInsightID, insightID: insightID)
                }
            } else {
                LoadingStateIndicator(loadingState: groupService.loadingState(for: groupID), title: groupService.group(withID: groupID)?.title)
            }
        }
        .padding(.vertical, spacing)
            
    }
}
