//
//  InsightGroupsView.swift
//  InsightGroupsView
//
//  Created by Daniel Jilg on 18.08.21.
//

import SwiftUI
import TelemetryClient

struct InsightGroupsView: View {
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var groupService: GroupService
    @EnvironmentObject var insightResultService: InsightResultService
    
    @State var sidebarVisible = false
    @State var selectedInsightGroupID: DTOv2.Group.ID?
    @State var selectedInsightID: DTOv2.Insight.ID?
    @State private var showDatePicker: Bool = false
    
    @Environment(\.horizontalSizeClass) var sizeClass
    
    private var groupsToolbarPlacement: ToolbarItemPlacement {
        if sizeClass == .compact {
            return .bottomBar
        } else {
            return .navigation
        }
    }
    
    let appID: DTOv2.App.ID
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StatusMessageDisplay()
            
            HStack {
                groupSelector
                
                Menu {
                    newGroupButton
                    if let selectedInsightGroupID = selectedInsightGroupID, sizeClass == .compact {
                        NewInsightMenu(appID: self.appID, selectedInsightGroupID: selectedInsightGroupID)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .padding(.horizontal)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            Divider()
            
            Group {
                if selectedInsightGroupID == nil {
                    EmptyAppView(appID: appID)
                        .frame(maxWidth: 400)
                        .padding()
                }
            
                selectedInsightGroupID.map {
                    GroupView(groupID: $0, selectedInsightID: $selectedInsightID, sidebarVisible: $sidebarVisible)
                        .background(Color.separatorColor)
                }
            }
        }
        .onAppear {
            selectedInsightGroupID = appService.app(withID: appID)?.insightGroupIDs.first
            TelemetryManager.send("InsightGroupsAppear")
        }
        .onReceive(appService.objectWillChange) { _ in
            if selectedInsightGroupID == nil {
                selectedInsightGroupID = appService.app(withID: appID)?.insightGroupIDs.first
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(appService.app(withID: appID)?.name ?? "Loading...")
        .toolbar {
            ToolbarItem {
                Button(insightResultService.timeIntervalDescription) {
                    self.showDatePicker = true
                }.popover(
                    isPresented: self.$showDatePicker,
                    arrowEdge: .bottom
                ) { InsightDataTimeIntervalPicker().padding() }
            }
        }
    }
    
    private var groupSelector: some View {
        Picker("Group", selection: $selectedInsightGroupID) {
            if let app = appService.app(withID: appID) {
                ForEach(
                    app.insightGroupIDs
                        .map { ($0, groupService.group(withID: $0)?.order ?? 0) }
                        .sorted(by: { $0.1 < $1.1 }),
                    id: \.0
                ) { idTuple in
                    TinyLoadingStateIndicator(
                        loadingState: groupService.loadingState(for: idTuple.0),
                        title: groupService.group(withID: idTuple.0)?.title
                    )
                    .tag(idTuple.0 as DTOv2.Group.ID?)
                }
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    private var newGroupButton: some View {
        Button {
            groupService.create(insightGroupNamed: "New Group", for: appID) { _ in
                appService.retrieveApp(with: appID)
            }
        } label: {
            Label("New Group", systemImage: "plus")
        }
    }
}
