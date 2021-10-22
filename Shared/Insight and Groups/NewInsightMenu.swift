//
//  NewInsightMenu.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 24.09.21.
//

import SwiftUI
import DataTransferObjects

struct NewInsightMenu: View {
    @EnvironmentObject var groupService: GroupService
    @EnvironmentObject var insightService: InsightService
    
    let appID: UUID
    let selectedInsightGroupID: UUID
    
    var body: some View {
        Menu {
            Section {
                Button("Generic Timeseries Insight") {
                    let definitionRequestBody = DTOv2.Insight.newTimeSeriesInsight(groupID: selectedInsightGroupID)
                    insightService.create(insightWith: definitionRequestBody) { _ in groupService.retrieveGroup(with: selectedInsightGroupID) }
                }
                            
                Button("Generic Breakdown Insight") {
                    let definitionRequestBody = DTOv2.Insight.newBreakdownInsight(groupID: selectedInsightGroupID)
                    insightService.create(insightWith: definitionRequestBody) { _ in groupService.retrieveGroup(with: selectedInsightGroupID) }
                }
            }
                        
            Section {
                Button("Daily Active Users") {
                    let definitionRequestBody = DTOv2.Insight.newDailyUserCountInsight(groupID: selectedInsightGroupID)
                    insightService.create(insightWith: definitionRequestBody) { _ in groupService.retrieveGroup(with: selectedInsightGroupID) }
                }
                            
                Button("Weekly Active Users") {
                    let definitionRequestBody = DTOv2.Insight.newWeeklyUserCountInsight(groupID: selectedInsightGroupID)
                    insightService.create(insightWith: definitionRequestBody) { _ in groupService.retrieveGroup(with: selectedInsightGroupID) }
                }
                            
                Button("Monthly Active Users") {
                    let definitionRequestBody = DTOv2.Insight.newMonthlyUserCountInsight(groupID: selectedInsightGroupID)
                    insightService.create(insightWith: definitionRequestBody) { _ in groupService.retrieveGroup(with: selectedInsightGroupID) }
                }
                            
                Button("Daily Signals") {
                    let definitionRequestBody = DTOv2.Insight.newSignalInsight(groupID: selectedInsightGroupID)
                    insightService.create(insightWith: definitionRequestBody) { _ in groupService.retrieveGroup(with: selectedInsightGroupID) }
                }
            }
                        
            Section {
                Button("App Versions Breakdown") {
                    let definitionRequestBody = DTOv2.Insight.newBreakdownInsight(
                        groupID: selectedInsightGroupID,
                        title: "App Versions Breakdown",
                        breakdownKey: "appVersion"
                    )
                    insightService.create(insightWith: definitionRequestBody) { _ in groupService.retrieveGroup(with: selectedInsightGroupID) }
                }
                            
                Button("Build Number Breakdown") {
                    let definitionRequestBody = DTOv2.Insight.newBreakdownInsight(
                        groupID: selectedInsightGroupID,
                        title: "Build Number Breakdown",
                        breakdownKey: "buildNumber"
                    )
                    insightService.create(insightWith: definitionRequestBody) { _ in groupService.retrieveGroup(with: selectedInsightGroupID) }
                }
                            
                Button("Device Type Breakdown") {
                    let definitionRequestBody = DTOv2.Insight.newBreakdownInsight(
                        groupID: selectedInsightGroupID,
                        title: "Device Type Breakdown",
                        breakdownKey: "modelName"
                    )
                    insightService.create(insightWith: definitionRequestBody) { _ in groupService.retrieveGroup(with: selectedInsightGroupID) }
                }
                            
                Button("OS Breakdown") {
                    let definitionRequestBody = DTOv2.Insight.newBreakdownInsight(
                        groupID: selectedInsightGroupID,
                        title: "OS Breakdown",
                        breakdownKey: "systemVersion"
                    )
                    insightService.create(insightWith: definitionRequestBody) { _ in groupService.retrieveGroup(with: selectedInsightGroupID) }
                }
            }
            
            Section {
                Button("Custom Query") {
                    let definitionRequestBody = DTOv2.Insight.newCustomQueryInsight(groupID: selectedInsightGroupID)
                    insightService.create(insightWith: definitionRequestBody) { _ in groupService.retrieveGroup(with: selectedInsightGroupID) }
                }
            }
        }
        label: {
            Label("New Insight", systemImage: "plus.rectangle")
        }
    }
}
