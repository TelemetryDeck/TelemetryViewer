//
//  NewInsightMenu.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 24.09.21.
//

import SwiftUI

struct NewInsightMenu: View {
    @EnvironmentObject var groupService: GroupService
    @EnvironmentObject var insightService: InsightService
    
    let appID: UUID
    let selectedInsightGroupID: UUID
    
    var body: some View {
        Menu {
            Section {
                Button("Generic Timeseries Insight") {
                    let definitionRequestBody = DTOsWithIdentifiers.Insight.newTimeSeriesInsight(groupID: selectedInsightGroupID)
                    insightService.create(insightWith: definitionRequestBody) { _ in groupService.retrieveGroup(with: selectedInsightGroupID) }
                }
                            
                Button("Generic Breakdown Insight") {
                    let definitionRequestBody = DTOsWithIdentifiers.Insight.newBreakdownInsight(groupID: selectedInsightGroupID)
                    insightService.create(insightWith: definitionRequestBody) { _ in groupService.retrieveGroup(with: selectedInsightGroupID) }
                }
            }
                        
            Section {
                Button("Daily Active Users") {
                    let definitionRequestBody = DTOsWithIdentifiers.Insight.newDailyUserCountInsight(groupID: selectedInsightGroupID)
                    insightService.create(insightWith: definitionRequestBody) { _ in groupService.retrieveGroup(with: selectedInsightGroupID) }
                }
                            
                Button("Weekly Active Users") {
                    let definitionRequestBody = DTOsWithIdentifiers.Insight.newWeeklyUserCountInsight(groupID: selectedInsightGroupID)
                    insightService.create(insightWith: definitionRequestBody) { _ in groupService.retrieveGroup(with: selectedInsightGroupID) }
                }
                            
                Button("Monthly Active Users") {
                    let definitionRequestBody = DTOsWithIdentifiers.Insight.newMonthlyUserCountInsight(groupID: selectedInsightGroupID)
                    insightService.create(insightWith: definitionRequestBody) { _ in groupService.retrieveGroup(with: selectedInsightGroupID) }
                }
                            
                Button("Daily Signals") {
                    let definitionRequestBody = DTOsWithIdentifiers.Insight.newSignalInsight(groupID: selectedInsightGroupID)
                    insightService.create(insightWith: definitionRequestBody) { _ in groupService.retrieveGroup(with: selectedInsightGroupID) }
                }
            }
                        
            Section {
                Button("App Versions Breakdown") {
                    let definitionRequestBody = DTOsWithIdentifiers.Insight.newBreakdownInsight(
                        groupID: selectedInsightGroupID,
                        title: "App Versions Breakdown",
                        breakdownKey: "appVersion"
                    )
                    insightService.create(insightWith: definitionRequestBody) { _ in groupService.retrieveGroup(with: selectedInsightGroupID) }
                }
                            
                Button("Build Number Breakdown") {
                    let definitionRequestBody = DTOsWithIdentifiers.Insight.newBreakdownInsight(
                        groupID: selectedInsightGroupID,
                        title: "Build Number Breakdown",
                        breakdownKey: "buildNumber"
                    )
                    insightService.create(insightWith: definitionRequestBody) { _ in groupService.retrieveGroup(with: selectedInsightGroupID) }
                }
                            
                Button("Device Type Breakdown") {
                    let definitionRequestBody = DTOsWithIdentifiers.Insight.newBreakdownInsight(
                        groupID: selectedInsightGroupID,
                        title: "Device Type Breakdown",
                        breakdownKey: "modelName"
                    )
                    insightService.create(insightWith: definitionRequestBody) { _ in groupService.retrieveGroup(with: selectedInsightGroupID) }
                }
                            
                Button("OS Breakdown") {
                    let definitionRequestBody = DTOsWithIdentifiers.Insight.newBreakdownInsight(
                        groupID: selectedInsightGroupID,
                        title: "OS Breakdown",
                        breakdownKey: "systemVersion"
                    )
                    insightService.create(insightWith: definitionRequestBody) { _ in groupService.retrieveGroup(with: selectedInsightGroupID) }
                }
            }
            
            Section {
                Button("Custom Query") {
                    let definitionRequestBody = DTOsWithIdentifiers.Insight.newCustomQueryInsight(groupID: selectedInsightGroupID)
                    insightService.create(insightWith: definitionRequestBody) { _ in groupService.retrieveGroup(with: selectedInsightGroupID) }
                }
            }
        }
        label: {
            Label("New Insight", systemImage: "plus.rectangle")
        }
    }
}
