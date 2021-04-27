//
//  AppRootView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 17.02.21.
//

import SwiftUI
import TelemetryModels

struct AppRootView: View {
    @EnvironmentObject var api: APIRepresentative
    let appID: UUID
    
    var app: TelemetryApp? { api.app(with: appID) }

    @State var selectedInsightGroupID: UUID = UUID()
    @State private var showingSheet = false

    private var insightGroup: InsightGroup? {
        guard let app = app else { return nil }
        return api.insightGroups[app]?.first { $0.id == selectedInsightGroupID }
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
            if let app = app, (api.insightGroups[app] ?? []).isEmpty == false {
                TabView(selection: $selectedInsightGroupID) {
                    ForEach(api.insightGroups[app] ?? []) { insightGroup in
                        InsightGroupView(appID: appID, insightGroupID: insightGroup.id)
                            .tabItem { Label(insightGroup.title, systemImage: "square.grid.2x2") }
                            .tag(AppRootViewSelection.insightGroup(group: insightGroup))
                    }
                }
            } else if app != nil {
                EmptyAppView(appID: appID)
                    .frame(maxWidth: 400)
                    .padding()
            } else {
                Text("No App Selected")
            }
        }
        .navigationBarTitle(app?.name ?? "No App Selected", displayMode: .inline)
        .sheet(isPresented: $showingSheet) {
            NavigationView {
                AppEditor(appID: appID)
            }
        }
        .toolbar {
            ToolbarItem {
                Menu {
                    Section {
                        Button("New Group") {
                            guard let app = app else { return }
                            api.create(insightGroupNamed: "New Group", for: app)
                        }

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

                    Section {
                        Menu {
                            Section {
                                Button(action: {
                                    api.timeWindowBeginning = Date().addingTimeInterval(-60 * 60 * 24 * 365)
                                    api.timeWindowEnd = nil
                                    api.reloadVisibleInsights()
                                }) {
                                    Label("Last Year", systemImage: "calendar")
                                }
                                Button(action: {
                                    api.timeWindowBeginning = Date().addingTimeInterval(-60 * 60 * 24 * 90)
                                    api.timeWindowEnd = nil
                                    api.reloadVisibleInsights()
                                }) {
                                    Label("Last 3 Months", systemImage: "calendar")
                                }

                                Button(action: {
                                    api.timeWindowBeginning = nil
                                    api.timeWindowEnd = nil
                                    api.reloadVisibleInsights()
                                }) {
                                    Label("Last Month", systemImage: "calendar")
                                }

                                Button(action: {
                                    api.timeWindowBeginning = Date().addingTimeInterval(-60 * 60 * 24 * 7)
                                    api.timeWindowEnd = nil
                                    api.reloadVisibleInsights()
                                }) {
                                    Label("Last Week", systemImage: "calendar")
                                }

                                Button(action: {
                                    api.timeWindowBeginning = Date().addingTimeInterval(-60 * 60 * 24)
                                    api.timeWindowEnd = nil
                                    api.reloadVisibleInsights()
                                }) {
                                    Label("Today", systemImage: "calendar")
                                }
                            }
                        }
                        label: {
                            Text(timeIntervalDescription)
                        }
                    }
                    
                    Button("App Settings") {
                        showingSheet = true
                    }
                } label: {
                    Label("Menu", systemImage: "ellipsis.circle")
                }
            }
        }
    }
}
