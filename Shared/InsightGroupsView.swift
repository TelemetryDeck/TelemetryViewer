//
//  InsightGroupsView.swift
//  InsightGroupsView
//
//  Created by Daniel Jilg on 18.08.21.
//

import SwiftUI

struct InsightGroupsView: View {
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var groupService: GroupService
    
    @State var sidebarVisible = false
    @State var selectedInsightGroupID: DTOsWithIdentifiers.Group.ID
    
    let appID: DTOsWithIdentifiers.App.ID
    
    var body: some View {
        GroupView(groupID: selectedInsightGroupID, sidebarVisible: $sidebarVisible)
            .navigationTitle(appService.app(withID: appID)?.name ?? "Loading...")
            .toolbar {
                ToolbarItemGroup(placement: .navigation) {
                    groupSelector
                }
                
                ToolbarItem {
                    LoadingStateIndicator(loadingState: appService.loadingState(for: appID), title: appService.app(withID: appID)?.name)
                }
                
                ToolbarItem {
                    sidebarToggleButton
                }
            }
    }
    
    private var sidebarToggleButton: some View {
        Button {
            withAnimation {
                sidebarVisible.toggle()
            }

        } label: {
            Image(systemName: "sidebar.right")
        }
        .help("Toggle right right sidebar")
    }
    
    private var groupSelector: some View {
        Picker("Group", selection: $selectedInsightGroupID) {
            if let app = appService.app(withID: appID) {
                ForEach(app.insightGroupIDs, id: \.self) { id in
                    TinyLoadingStateIndicator(loadingState: groupService.loadingState(for: id), title: groupService.group(withID: id)?.title)
                }
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}
