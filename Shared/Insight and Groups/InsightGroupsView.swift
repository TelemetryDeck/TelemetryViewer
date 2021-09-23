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
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var sizeClass
    #endif
    
    private var groupsToolbarPlacement: ToolbarItemPlacement {
        #if os(macOS)
        return .navigation
        #else
        if sizeClass == .compact {
            return .bottomBar
        } else {
            return .navigation
        }
        #endif
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
                }
            }
            
            #if os(iOS)
            Divider()
            
            VStack {
                HStack {
                    newGroupButton
                    if let selectedInsightGroupID = selectedInsightGroupID, sizeClass == .compact {
                        newInsightMenu(selectedInsightGroupID: selectedInsightGroupID)
                    }
                    
                    if sizeClass == .compact {
                        Spacer()
                    
                        sidebarToggleButton
                    }
                }
                
                groupSelector
            }
            .padding()

            .background(Color.cardBackground.opacity(0.9).ignoresSafeArea())
            #endif
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
            #if os(macOS)
            ToolbarItemGroup(placement: groupsToolbarPlacement) {
                groupSelector
                newGroupButton
            }
            #endif
                
            ToolbarItem {
                Button(insightResultService.timeIntervalDescription) {
                    self.showDatePicker = true
                }.popover(
                    isPresented: self.$showDatePicker,
                    arrowEdge: .bottom
                ) { InsightDataTimeIntervalPicker().padding() }
            }
            
            #if os(iOS)
            ToolbarItem {
                if let selectedInsightGroupID = selectedInsightGroupID, sizeClass != .compact {
                    newInsightMenu(selectedInsightGroupID: selectedInsightGroupID)
                }
            }
            #else
            ToolbarItem {
                if let selectedInsightGroupID = selectedInsightGroupID {
                    newInsightMenu(selectedInsightGroupID: selectedInsightGroupID)
                }
            }
            #endif
               
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
        #if os(iOS)
        Button {
            groupService.create(insightGroupNamed: "New Group", for: appID) { _ in
                appService.retrieveApp(with: appID)
            }
        } label: {
            Label("New", systemImage: "plus")
        }

        #else
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
        #endif
    }
    
    private func newInsightMenu(selectedInsightGroupID: UUID) -> some View {
        Menu {
            Section {
                Button("Generic Timeseries Insight") {
                    let definitionRequestBody = InsightDefinitionRequestBody.newTimeSeriesInsight(groupID: selectedInsightGroupID)
                    groupService.create(insightWith: definitionRequestBody, in: selectedInsightGroupID, for: appID)
                }
                        
                Button("Generic Breakdown Insight") {
                    let definitionRequestBody = InsightDefinitionRequestBody.newBreakdownInsight(groupID: selectedInsightGroupID)
                    groupService.create(insightWith: definitionRequestBody, in: selectedInsightGroupID, for: appID)
                }
            }
                    
            Section {
                Button("Daily Active Users") {
                    let definitionRequestBody = InsightDefinitionRequestBody.newDailyUserCountInsight(groupID: selectedInsightGroupID)
                    groupService.create(insightWith: definitionRequestBody, in: selectedInsightGroupID, for: appID)
                }
                        
                Button("Weekly Active Users") {
                    let definitionRequestBody = InsightDefinitionRequestBody.newWeeklyUserCountInsight(groupID: selectedInsightGroupID)
                    groupService.create(insightWith: definitionRequestBody, in: selectedInsightGroupID, for: appID)
                }
                        
                Button("Monthly Active Users") {
                    let definitionRequestBody = InsightDefinitionRequestBody.newMonthlyUserCountInsight(groupID: selectedInsightGroupID)
                    groupService.create(insightWith: definitionRequestBody, in: selectedInsightGroupID, for: appID)
                }
                        
                Button("Daily Signals") {
                    let definitionRequestBody = InsightDefinitionRequestBody.newSignalInsight(groupID: selectedInsightGroupID)
                    groupService.create(insightWith: definitionRequestBody, in: selectedInsightGroupID, for: appID)
                }
            }
                    
            Section {
                Button("App Versions Breakdown") {
                    let definitionRequestBody = InsightDefinitionRequestBody.newBreakdownInsight(
                        groupID: selectedInsightGroupID,
                        title: "App Versions Breakdown",
                        breakdownKey: "appVersion"
                    )
                    groupService.create(insightWith: definitionRequestBody, in: selectedInsightGroupID, for: appID)
                }
                        
                Button("Build Number Breakdown") {
                    let definitionRequestBody = InsightDefinitionRequestBody.newBreakdownInsight(
                        groupID: selectedInsightGroupID,
                        title: "Build Number Breakdown",
                        breakdownKey: "buildNumber"
                    )
                    groupService.create(insightWith: definitionRequestBody, in: selectedInsightGroupID, for: appID)
                }
                        
                Button("Device Type Breakdown") {
                    let definitionRequestBody = InsightDefinitionRequestBody.newBreakdownInsight(
                        groupID: selectedInsightGroupID,
                        title: "Device Type Breakdown",
                        breakdownKey: "modelName"
                    )
                    groupService.create(insightWith: definitionRequestBody, in: selectedInsightGroupID, for: appID)
                }
                        
                Button("OS Breakdown") {
                    let definitionRequestBody = InsightDefinitionRequestBody.newBreakdownInsight(
                        groupID: selectedInsightGroupID,
                        title: "OS Breakdown",
                        breakdownKey: "systemVersion"
                    )
                    groupService.create(insightWith: definitionRequestBody, in: selectedInsightGroupID, for: appID)
                }
            }
        }
        label: {
            Label("New Insight", systemImage: "plus.rectangle")
        }
    }
}
