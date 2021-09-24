//
//  NewInsightMenu.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 24.09.21.
//

import SwiftUI

struct NewInsightMenu: View {
    @EnvironmentObject var groupService: GroupService
    
    let appID: UUID
    let selectedInsightGroupID: UUID
    
    var body: some View {
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
