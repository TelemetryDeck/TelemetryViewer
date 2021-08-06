//
//  AppRootView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 17.02.21.
//

import SwiftUI

struct AppRootView: View {
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var insightService: InsightService
    @EnvironmentObject var insightCalculationService: InsightCalculationService
    @State private var showDatePicker: Bool = false
    
    let appID: UUID
    
    var body: some View {
        Group {
            if let selectedInsightGroupID = insightService.selectedInsightGroupID {
                InsightGroupView(appID: appID, insightGroupID: selectedInsightGroupID)
            } else {
                EmptyAppView(appID: appID)
                    .frame(maxWidth: 400)
                    .padding()
            }
        }
        .navigationTitle(appService.getSelectedApp()?.name ?? "No App Selected")
        .onAppear {
            insightService.selectedInsightGroupID = nil
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                Picker("View Mode", selection: $insightService.selectedInsightGroupID) {
                    ForEach(insightService.insightGroups(for: appID) ?? []) { insightGroup in
                        Text(insightGroup.title).tag(insightGroup.id as UUID?)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                    
                if appService.getSelectedApp() != nil {
                    Button(action: {
                        insightService.create(insightGroupNamed: "New Group", for: appID)
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
                if let selectedInsightGroupID = insightService.selectedInsightGroupID, let insightGroup = insightService.insightGroup(id: selectedInsightGroupID, in: appID), appService.getSelectedApp() != nil {
                    Menu {
                        Section {
                            Button("Generic Timeseries Insight") {
                                let definitionRequestBody = InsightDefinitionRequestBody.newTimeSeriesInsight(groupID: insightGroup.id)
                                insightService.create(insightWith: definitionRequestBody, in: insightGroup.id, for: appID)
                            }
                            
                            Button("Generic Breakdown Insight") {
                                let definitionRequestBody = InsightDefinitionRequestBody.newBreakdownInsight(groupID: insightGroup.id)
                                insightService.create(insightWith: definitionRequestBody, in: insightGroup.id, for: appID)
                            }
                        }
                        
                        Section {
                            Button("Daily Active Users") {
                                let definitionRequestBody = InsightDefinitionRequestBody.newDailyUserCountInsight(groupID: insightGroup.id)
                                insightService.create(insightWith: definitionRequestBody, in: insightGroup.id, for: appID)
                            }
                            
                            Button("Weekly Active Users") {
                                let definitionRequestBody = InsightDefinitionRequestBody.newWeeklyUserCountInsight(groupID: insightGroup.id)
                                insightService.create(insightWith: definitionRequestBody, in: insightGroup.id, for: appID)
                            }
                            
                            Button("Monthly Active Users") {
                                let definitionRequestBody = InsightDefinitionRequestBody.newMonthlyUserCountInsight(groupID: insightGroup.id)
                                insightService.create(insightWith: definitionRequestBody, in: insightGroup.id, for: appID)
                            }
                            
                            Button("Daily Signals") {
                                let definitionRequestBody = InsightDefinitionRequestBody.newSignalInsight(groupID: insightGroup.id)
                                insightService.create(insightWith: definitionRequestBody, in: insightGroup.id, for: appID)
                            }
                        }
                        
                        Section {
                            Button("App Versions Breakdown") {
                                let definitionRequestBody = InsightDefinitionRequestBody.newBreakdownInsight(
                                    groupID: insightGroup.id,
                                    title: "App Versions Breakdown",
                                    breakdownKey: "appVersion"
                                )
                                insightService.create(insightWith: definitionRequestBody, in: insightGroup.id, for: appID)
                            }
                            
                            Button("Build Number Breakdown") {
                                let definitionRequestBody = InsightDefinitionRequestBody.newBreakdownInsight(
                                    groupID: insightGroup.id,
                                    title: "Build Number Breakdown",
                                    breakdownKey: "buildNumber"
                                )
                                insightService.create(insightWith: definitionRequestBody, in: insightGroup.id, for: appID)
                            }
                            
                            Button("Device Type Breakdown") {
                                let definitionRequestBody = InsightDefinitionRequestBody.newBreakdownInsight(
                                    groupID: insightGroup.id,
                                    title: "Device Type Breakdown",
                                    breakdownKey: "modelName"
                                )
                                insightService.create(insightWith: definitionRequestBody, in: insightGroup.id, for: appID)
                            }
                            
                            Button("OS Breakdown") {
                                let definitionRequestBody = InsightDefinitionRequestBody.newBreakdownInsight(
                                    groupID: insightGroup.id,
                                    title: "OS Breakdown",
                                    breakdownKey: "systemVersion"
                                )
                                insightService.create(insightWith: definitionRequestBody, in: insightGroup.id, for: appID)
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
