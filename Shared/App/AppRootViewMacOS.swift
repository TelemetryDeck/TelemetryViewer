//
//  AppRootView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 17.02.21.
//

import SwiftUI

struct AppRootView: View {
    @EnvironmentObject var api: APIRepresentative
    @EnvironmentObject var insightService: InsightService
    @EnvironmentObject var insightCalculationService: InsightCalculationService
    @State private var showDatePicker: Bool = false
    
    let appID: UUID
    
    var app: TelemetryApp? { api.app(with: appID) }
    
    
    var body: some View {
        Group {
            if let selectedInsightGroupID = insightService.selectedInsightGroupID {
                InsightGroupView(appID: appID, insightGroupID: selectedInsightGroupID)
            } else {
                Text("...")
            }
        }
        .navigationTitle(app?.name ?? "No App Selected")
        .onAppear {
            insightService.selectedInsightGroupID = nil
            setupSidebars()
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                Picker("View Mode", selection: $insightService.selectedInsightGroupID) {
                    ForEach(insightService.insightGroups(for: appID) ?? []) { insightGroup in
                        Text(insightGroup.title).tag(insightGroup.id as UUID?)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                    
                if let app = app {
                    Button(action: {
                        api.create(insightGroupNamed: "New Group", for: app)
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("New Group")
                        }
                    }
                }
            }
            
            ToolbarItem {
                Button(insightCalculationService.timeIntervalDescription) {
                    self.showDatePicker = true
                }.popover(
                    isPresented: self.$showDatePicker,
                    arrowEdge: .bottom
                ) { InsightDataTimeIntervalPicker().padding() }
            }
            
            ToolbarItem {
                if let selectedInsightGroupID = insightService.selectedInsightGroupID, let insightGroup = insightService.insightGroup(id: selectedInsightGroupID, in: appID), let app = app {
                    Menu {
                        Section {
                            Button("Generic Timeseries Insight") {
                                let definitionRequestBody = InsightDefinitionRequestBody.newTimeSeriesInsight(groupID: insightGroup.id)
                                api.create(insightWith: definitionRequestBody, in: insightGroup, for: app) { _ in api.getInsightGroups(for: app) }
                            }
                            
                            Button("Generic Breakdown Insight") {
                                let definitionRequestBody = InsightDefinitionRequestBody.newBreakdownInsight(groupID: insightGroup.id)
                                api.create(insightWith: definitionRequestBody, in: insightGroup, for: app) { _ in api.getInsightGroups(for: app) }
                            }
                        }
                        
                        Section {
                            Button("Daily Active Users") {
                                let definitionRequestBody = InsightDefinitionRequestBody.newDailyUserCountInsight(groupID: insightGroup.id)
                                api.create(insightWith: definitionRequestBody, in: insightGroup, for: app) { _ in api.getInsightGroups(for: app) }
                            }
                            
                            Button("Weekly Active Users") {
                                let definitionRequestBody = InsightDefinitionRequestBody.newWeeklyUserCountInsight(groupID: insightGroup.id)
                                api.create(insightWith: definitionRequestBody, in: insightGroup, for: app) { _ in api.getInsightGroups(for: app) }
                            }
                            
                            Button("Monthly Active Users") {
                                let definitionRequestBody = InsightDefinitionRequestBody.newMonthlyUserCountInsight(groupID: insightGroup.id)
                                api.create(insightWith: definitionRequestBody, in: insightGroup, for: app) { _ in api.getInsightGroups(for: app) }
                            }
                            
                            Button("Daily Signals") {
                                let definitionRequestBody = InsightDefinitionRequestBody.newSignalInsight(groupID: insightGroup.id)
                                api.create(insightWith: definitionRequestBody, in: insightGroup, for: app) { _ in api.getInsightGroups(for: app) }
                            }
                        }
                        
                        Section {
                            Button("App Versions Breakdown") {
                                let definitionRequestBody = InsightDefinitionRequestBody.newBreakdownInsight(
                                    groupID: insightGroup.id,
                                    title: "App Versions Breakdown",
                                    breakdownKey: "appVersion"
                                )
                                api.create(insightWith: definitionRequestBody, in: insightGroup, for: app) { _ in api.getInsightGroups(for: app) }
                            }
                            
                            Button("Build Number Breakdown") {
                                let definitionRequestBody = InsightDefinitionRequestBody.newBreakdownInsight(
                                    groupID: insightGroup.id,
                                    title: "Build Number Breakdown",
                                    breakdownKey: "buildNumber"
                                )
                                api.create(insightWith: definitionRequestBody, in: insightGroup, for: app) { _ in api.getInsightGroups(for: app) }
                            }
                            
                            Button("Device Type Breakdown") {
                                let definitionRequestBody = InsightDefinitionRequestBody.newBreakdownInsight(
                                    groupID: insightGroup.id,
                                    title: "Device Type Breakdown",
                                    breakdownKey: "modelName"
                                )
                                api.create(insightWith: definitionRequestBody, in: insightGroup, for: app) { _ in api.getInsightGroups(for: app) }
                            }
                            
                            Button("OS Breakdown") {
                                let definitionRequestBody = InsightDefinitionRequestBody.newBreakdownInsight(
                                    groupID: insightGroup.id,
                                    title: "OS Breakdown",
                                    breakdownKey: "systemVersion"
                                )
                                api.create(insightWith: definitionRequestBody, in: insightGroup, for: app) { _ in api.getInsightGroups(for: app) }
                            }
                        }
                    }
                    label: {
                        Label("New Insight", systemImage: "plus.rectangle")
                    }
                }
            }
        }
    }
}
