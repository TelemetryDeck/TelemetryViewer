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
    
    let appID: DTOsWithIdentifiers.App.ID
    
    var body: some View {
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
            ToolbarItemGroup(placement: .navigation) {
                groupSelector
                
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
                ForEach(app.insightGroupIDs, id: \.self) { id in
                    TinyLoadingStateIndicator(loadingState: groupService.loadingState(for: id), title: groupService.group(withID: id)?.title)
                        .tag(id as DTOsWithIdentifiers.Group.ID?)
                }
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}
