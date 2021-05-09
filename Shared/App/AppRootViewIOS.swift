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

    @State var selectedInsightGroupID: UUID = UUID()
    @State private var newInsightGroupID: UUID?

    private var insightGroup: DTO.InsightGroup? {
        guard let app = app else { return nil }
        return api.insightGroups[app]?.first { $0.id == selectedInsightGroupID }
    }
    
    func newInsight(_ definitionRequestBody: InsightDefinitionRequestBody, app: TelemetryApp) {
        guard
            let insightGroup = ((api.insightGroups[app] ?? []).first { $0.id == definitionRequestBody.groupID })
        else { return }
        
        api.create(insightWith: definitionRequestBody, in: insightGroup, for: app) { _ in api.getInsightGroups(for: app) }
    }
    
    var body: some View {
        if let app = app {
            
            List {
                if (api.insightGroups[app] ?? []).isEmpty {
                    EmptyAppView(appID: appID)
                }
                
                ForEach(api.insightGroups[app] ?? []) { insightGroup in
                    Section(header: Text(insightGroup.title)) {
                        let sortedInsights = insightGroup.insights.sorted
                        {
                            
                            if $0.isExpanded != $1.isExpanded {
                                return $0.isExpanded && !$1.isExpanded
                            }
                            else {
                                return  $0.order ?? 0 < $1.order ?? 0
                            }
                        }
                        
                        ForEach(sortedInsights) { insight in
                            let destination = InsightEditor(appID: appID, insightGroupID: insightGroup.id, insightID: insight.id)
                            NavigationLink(destination: destination) {
                                InsightView(topSelectedInsightID: .constant(nil), app: app, insightGroup: insightGroup, insight: insight)
                            }
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                            .buttonStyle(CardButtonStyle(isSelected: false))
                        }
                        
                        
                        NavigationLink(destination: InsightGroupEditor(app: app, insightGroup: insightGroup)) {
                            Label("Edit \(insightGroup.title)", systemImage: "pencil")
                        }
                        
                        Button {
                            newInsightGroupID = insightGroup.id
                        } label: {
                            Label("New Insight in \(insightGroup.title)", systemImage: "plus")
                        }
                        .actionSheet(item: $newInsightGroupID) { newInsightGroupID in
                            ActionSheet(
                                title: Text("New Insight"),
                                message: Text("Please select one of these template insights to get started"),
                                buttons: [
                                    .cancel { self.newInsightGroupID = nil },
                                    .default(Text("Generic Time Series Insight")) { newInsight(.newTimeSeriesInsight(groupID: newInsightGroupID), app: app) },
                                    .default(Text("Generic Breakdown Insight")) { newInsight(.newBreakdownInsight(groupID: newInsightGroupID), app: app) },
                                    
                                    .default(Text("Daily Active Users")) { newInsight(.newDailyUserCountInsight(groupID: newInsightGroupID), app: app) },
                                    .default(Text("Weekly Active Users")) { newInsight(.newDailyUserCountInsight(groupID: newInsightGroupID), app: app) },
                                    .default(Text("Monthly Active Users")) { newInsight(.newMonthlyUserCountInsight(groupID: newInsightGroupID), app: app) },
                                    .default(Text("Daily Signals")) { newInsight(.newSignalInsight(groupID: newInsightGroupID), app: app) },
                                    
                                    .default(Text("App Versions Breakdown")) { newInsight(.newBreakdownInsight(groupID: newInsightGroupID, title: "App Versions Breakdown", breakdownKey: "appVersion"), app: app) },
                                    .default(Text("Build Number Breakdown")) { newInsight(.newBreakdownInsight(groupID: newInsightGroupID, title: "Build Number Breakdown", breakdownKey: "buildNumber"), app: app) },
                                    .default(Text("Device Type Breakdown")) { newInsight(.newBreakdownInsight(groupID: newInsightGroupID, title: "Device Type Breakdown", breakdownKey: "modelName"), app: app) },
                                    .default(Text("OS Breakdown")) { newInsight(.newBreakdownInsight(groupID: newInsightGroupID, title: "OS Breakdown", breakdownKey: "systemVersion"), app: app) }
                                ]
                            )
                        }
                    }
                }
            }
            .navigationBarTitle(app.name)
            .modifier(AddAppRootViewModifier(appID: appID))
            
        } else {
            Text("No App Selected")
        }
    }
}


struct AddAppRootViewModifier: ViewModifier {
    @EnvironmentObject var api: APIRepresentative
    let appID: UUID
    
    var app: TelemetryApp? { api.app(with: appID) }

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
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    func body(content: Content) -> some View {
        if let app = app {
        
        content
            .toolbar {
                ToolbarItem {
                    Menu {
                        Section {
                            Section {
                                Button("New Group") {
                                    api.create(insightGroupNamed: "New Group", for: app)
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
                    } label: {
                        Label("Menu", systemImage: "ellipsis.circle")
                    }
                }
            }
            
            } else {
                content
            }
    }
}

extension UUID: Identifiable {
    public var id: UUID { return self }
}
