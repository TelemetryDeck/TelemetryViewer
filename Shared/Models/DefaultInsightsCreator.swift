//
//  DefaultInsightsCreator.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 19.10.20.
//

import Foundation

extension APIRepresentative {
    func createDefaultInsights(for app: TelemetryApp) {
        create(insightGroupNamed: "Users", for: app) {
            self.getInsightGroups(for: app) {
                guard let currentGroup = self.insightGroups[app]?.first(where: { $0.title == "Users" }) else { return }
                
                var insightRequest: [InsightDefinitionRequestBody] = []
                
                insightRequest.append(InsightDefinitionRequestBody(
                                        order: 1,
                                        title: "Active Users Today",
                                        subtitle: "Number of Users of your App in the last 24 hours",
                                        signalType: nil,
                                        uniqueUser: true,
                                        filters: [:],
                                        rollingWindowSize: -24*3600,
                                        breakdownKey: nil,
                                        displayMode: .number,
                                        isExpanded: true))
                
                insightRequest.append(InsightDefinitionRequestBody(
                                        order: 1,
                                        title: "Daily Active Users",
                                        subtitle: "Development of Daily Active Users over time",
                                        signalType: nil,
                                        uniqueUser: true,
                                        filters: [:],
                                        rollingWindowSize: -24*3600,
                                        breakdownKey: nil,
                                        displayMode: .lineChart,
                                        isExpanded: false))
                
                insightRequest.append(InsightDefinitionRequestBody(
                                        order: 1,
                                        title: "Weekly Active Users",
                                        subtitle: "Development of Weekly Active Users over time",
                                        signalType: nil,
                                        uniqueUser: true,
                                        filters: [:],
                                        rollingWindowSize: -24*3600*7,
                                        breakdownKey: nil,
                                        displayMode: .lineChart,
                                        isExpanded: false))
                
                insightRequest.append(InsightDefinitionRequestBody(
                                        order: 1,
                                        title: "Monthly Active Users",
                                        subtitle: "Development of Monthly Active Users over time",
                                        signalType: nil,
                                        uniqueUser: true,
                                        filters: [:],
                                        rollingWindowSize: -24*3600*30,
                                        breakdownKey: nil,
                                        displayMode: .lineChart,
                                        isExpanded: false))
                
                insightRequest.forEach { self.create(insightWith: $0, in: currentGroup, for: app) }
            }
        }
        
        create(insightGroupNamed: "Platforms", for: app) {
            self.getInsightGroups(for: app) {
                guard let currentGroup = self.insightGroups[app]?.first(where: { $0.title == "Platforms" }) else { return }
                
                var insightRequest: [InsightDefinitionRequestBody] = []
                
                insightRequest.append(InsightDefinitionRequestBody(
                                        order: 1,
                                        title: "Platform Breakdown",
                                        subtitle: "Breakdown of your users' platforms in the last week",
                                        signalType: nil,
                                        uniqueUser: true,
                                        filters: [:],
                                        rollingWindowSize: -24*3600*7,
                                        breakdownKey: "platform",
                                        displayMode: .pieChart,
                                        isExpanded: true))
                
                insightRequest.append(InsightDefinitionRequestBody(
                                        order: 1,
                                        title: "iOS Versions Breakdown",
                                        subtitle: "Which iOS versions were your users using over the last week?",
                                        signalType: nil,
                                        uniqueUser: true,
                                        filters: ["platform": "iOS"],
                                        rollingWindowSize: -24*3600*7,
                                        breakdownKey: "systemVersion",
                                        displayMode: .pieChart,
                                        isExpanded: false))
                
                insightRequest.append(InsightDefinitionRequestBody(
                                        order: 1,
                                        title: "macOS Versions Breakdown",
                                        subtitle: "Which macOS versions were your users using over the last week?",
                                        signalType: nil,
                                        uniqueUser: true,
                                        filters: ["platform": "macOS"],
                                        rollingWindowSize: -24*3600*7,
                                        breakdownKey: "systemVersion",
                                        displayMode: .pieChart,
                                        isExpanded: false))
                
                insightRequest.forEach { self.create(insightWith: $0, in: currentGroup, for: app) }
            }
        }
        
        create(insightGroupNamed: "Signals", for: app) {
            self.getInsightGroups(for: app) {
                guard let currentGroup = self.insightGroups[app]?.first(where: { $0.title == "Signals" }) else { return }
                
                var insightRequest: [InsightDefinitionRequestBody] = []
                
                insightRequest.append(InsightDefinitionRequestBody(
                                        order: 1,
                                        title: "Signals Today",
                                        subtitle: "How many Signals did Telemetry receive from your app's users' in the last 24 hours?",
                                        signalType: nil,
                                        uniqueUser: false,
                                        filters: [:],
                                        rollingWindowSize: -24*3600,
                                        breakdownKey: nil,
                                        displayMode: .number,
                                        isExpanded: false))
                
                insightRequest.append(InsightDefinitionRequestBody(
                                        order: 1,
                                        title: "Signals Types",
                                        subtitle: "What types of Signals did Telemetry receive from your app's users?",
                                        signalType: nil,
                                        uniqueUser: false,
                                        filters: [:],
                                        rollingWindowSize: -24*3600,
                                        breakdownKey: "signalType",
                                        displayMode: .pieChart,
                                        isExpanded: false))
                
                insightRequest.append(InsightDefinitionRequestBody(
                                        order: 1,
                                        title: "Hourly Signals",
                                        subtitle: nil,
                                        signalType: nil,
                                        uniqueUser: false,
                                        filters: [:],
                                        rollingWindowSize: -3600,
                                        breakdownKey: nil,
                                        displayMode: .lineChart,
                                        isExpanded: false))
                
                insightRequest.forEach { self.create(insightWith: $0, in: currentGroup, for: app) }
            }
        }
        
        create(insightGroupNamed: "Versions", for: app) {
            self.getInsightGroups(for: app) {
                guard let currentGroup = self.insightGroups[app]?.first(where: { $0.title == "Versions" }) else { return }
                
                var insightRequest: [InsightDefinitionRequestBody] = []
                
                insightRequest.append(InsightDefinitionRequestBody(
                                        order: 1,
                                        title: "App Versions",
                                        subtitle: "Which versions of the app were people using in the last 7 days?",
                                        signalType: nil,
                                        uniqueUser: true,
                                        filters: [:],
                                        rollingWindowSize: -24*3600*7,
                                        breakdownKey: "appVersion",
                                        displayMode: .pieChart,
                                        isExpanded: true))
                
                insightRequest.append(InsightDefinitionRequestBody(
                                        order: 1,
                                        title: "Build Numbers",
                                        subtitle: "Which Build Numbers were people using in the last 7 days?",
                                        signalType: nil,
                                        uniqueUser: true,
                                        filters: [:],
                                        rollingWindowSize: -24*3600*7,
                                        breakdownKey: "buildNumber",
                                        displayMode: .pieChart,
                                        isExpanded: false))
                
                insightRequest.forEach { self.create(insightWith: $0, in: currentGroup, for: app) }
            }
        }
    }
}
