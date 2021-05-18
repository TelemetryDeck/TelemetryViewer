//
//  AppRootView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 17.02.21.
//

import SwiftUI

struct AppRootView: View {
    @EnvironmentObject var api: APIRepresentative
    let appID: UUID
    
    var app: TelemetryApp? { api.app(with: appID) }
    @State var selectedInsightGroupID = UUID()
    
    @State var selection: AppRootViewSelection = .noSelection
    
    @State var timeWindowBeginning = Date()
    @State var timeWindowEnd = Date() - 30 * 24 * 3600
    
    private var insightGroup: DTO.InsightGroup? {
        switch selection {
        case let .insightGroup(group):
            return group
        default:
            return nil
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    var timeIntervalDescription: String {
        let displayTimeWindowEnd = api.timeWindowEnd ?? Date()
        let displayTimeWindowBegin = api.timeWindowBeginning ??
            displayTimeWindowEnd.addingTimeInterval(-60 * 60 * 24 * 30)
        
        if api.timeWindowEnd == nil {
            if api.timeWindowBeginning == nil {
                return "Showing Last 30 Days"
            } else {
                let components = Calendar.current.dateComponents([.day], from: displayTimeWindowBegin, to: displayTimeWindowEnd)
                return "Showing Last \(components.day ?? 0) Days"
            }
        } else {
            return "\(dateFormatter.string(from: displayTimeWindowBegin)) – \(dateFormatter.string(from: displayTimeWindowEnd))"
        }
    }
    
    var body: some View {
        Group {
            switch selection {
            case .lexicon:
                LexiconView(appID: appID)
            case .rawSignals:
                SignalList(appID: appID)
            case let .insightGroup(group):
                InsightGroupView(appID: appID, insightGroupID: group.id)
            case .noSelection:
                EmptyAppView(appID: appID)
                    .frame(maxWidth: 400)
                    .padding()
            }
        }
        .navigationTitle(app?.name ?? "No App Selected")
        .onAppear {
            if let app = app, let firstInsightGroup = api.insightGroups[app]?.first, selection == .noSelection {
                selection = .insightGroup(group: firstInsightGroup)
            }
            
            timeWindowEnd = api.timeWindowEnd ?? Date()
            timeWindowBeginning = api.timeWindowBeginning ?? Date() - 30 * 24 * 3600
            
            setupSidebars()
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                if let app = app {
                    Picker("View Mode", selection: $selection) {
                        ForEach(api.insightGroups[app] ?? []) { insightGroup in
                            Text(insightGroup.title).tag(AppRootViewSelection.insightGroup(group: insightGroup))
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                    
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
                InsightDataTimeIntervalPicker()
            }
            
            ToolbarItem {
                if let insightGroup = insightGroup, let app = app {
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
