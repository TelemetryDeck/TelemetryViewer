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
    @State var selectedInsightGroupID: DTOsWithIdentifiers.Group.ID?
    @State var selectedInsightID: DTOsWithIdentifiers.Insight.ID?
    @State private var showDatePicker: Bool = false
    
    private var groupsToolbarPlacement: ToolbarItemPlacement {
        return .navigation
    }
    
    let appID: DTOsWithIdentifiers.App.ID
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StatusMessageDisplay()
            
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
        
        .navigationTitle(appService.app(withID: appID)?.name ?? "Loading...")
        .toolbar {
            ToolbarItemGroup(placement: groupsToolbarPlacement) {
                groupSelector
                newGroupButton
            }
                
            ToolbarItem {
                Button(insightResultService.timeIntervalDescription) {
                    self.showDatePicker = true
                }.popover(
                    isPresented: self.$showDatePicker,
                    arrowEdge: .bottom
                ) { InsightDataTimeIntervalPicker().padding() }
            }
            
            ToolbarItem {
                if let selectedInsightGroupID = selectedInsightGroupID {
                    NewInsightMenu(appID: appID, selectedInsightGroupID: selectedInsightGroupID)
                }
            }
               
            ToolbarItem {
                sidebarToggleButton
            }
        }
    }

    private var sidebarToggleButton: some View {
        Button {
            TelemetryManager.send("InsightGroupsSidebarToggle")
            
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
                    .tag(idTuple.0 as DTOsWithIdentifiers.Group.ID?)
                }
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    private var newGroupButton: some View {
        Button(action: {
            groupService.create(insightGroupNamed: "New Group", for: appID) { _ in
                appService.retrieveApp(with: appID)
            }
        }) {
            HStack {
                Image(systemName: "plus")
                Text("New Group")
            }
        }
    }
}
