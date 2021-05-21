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
    @State private var newInsightGroupID: UUID?

    let appID: UUID

    func newInsight(_ definitionRequestBody: InsightDefinitionRequestBody, appID: UUID) {
        guard let groupID = definitionRequestBody.groupID else { return }
        insightService.create(insightWith: definitionRequestBody, in: groupID, for: appID)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                if insightService.insightGroups(for: appID) == nil {
                    ProgressView()
                } else if (insightService.insightGroups(for: appID) ?? []).isEmpty {
                    EmptyAppView(appID: appID)
                } else {
                    ForEach(insightService.insightGroups(for: appID) ?? []) { insightGroup in
                        Section(header: Text(insightGroup.title)) {
                            let sortedInsights = insightGroup.insights.sorted {
                                if $0.isExpanded != $1.isExpanded {
                                    return $0.isExpanded && !$1.isExpanded
                                } else {
                                    return $0.order ?? 0 < $1.order ?? 0
                                }
                            }

                            ForEach(sortedInsights) { insight in
                                let destination = InsightEditor(appID: appID, insightGroupID: insightGroup.id, insightID: insight.id)
                                NavigationLink(destination: destination) {
                                    InsightView(topSelectedInsightID: .constant(nil), appID: appID, insightGroupID: insightGroup.id, insightID: insight.id)
                                }
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                                .buttonStyle(CardButtonStyle(isSelected: false))
                            }

                            NavigationLink(destination: InsightGroupEditor(appID: appID, insightGroup: insightGroup)) {
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
                                        .default(Text("Generic Time Series Insight")) { newInsight(.newTimeSeriesInsight(groupID: newInsightGroupID), appID: appID) },
                                        .default(Text("Generic Breakdown Insight")) { newInsight(.newBreakdownInsight(groupID: newInsightGroupID), appID: appID) },

                                        .default(Text("Daily Active Users")) { newInsight(.newDailyUserCountInsight(groupID: newInsightGroupID), appID: appID) },
                                        .default(Text("Weekly Active Users")) { newInsight(.newDailyUserCountInsight(groupID: newInsightGroupID), appID: appID) },
                                        .default(Text("Monthly Active Users")) { newInsight(.newMonthlyUserCountInsight(groupID: newInsightGroupID), appID: appID) },
                                        .default(Text("Daily Signals")) { newInsight(.newSignalInsight(groupID: newInsightGroupID), appID: appID) },

                                        .default(Text("App Versions Breakdown")) { newInsight(.newBreakdownInsight(groupID: newInsightGroupID, title: "App Versions Breakdown", breakdownKey: "appVersion"), appID: appID) },
                                        .default(Text("Build Number Breakdown")) { newInsight(.newBreakdownInsight(groupID: newInsightGroupID, title: "Build Number Breakdown", breakdownKey: "buildNumber"), appID: appID) },
                                        .default(Text("Device Type Breakdown")) { newInsight(.newBreakdownInsight(groupID: newInsightGroupID, title: "Device Type Breakdown", breakdownKey: "modelName"), appID: appID) },
                                        .default(Text("OS Breakdown")) { newInsight(.newBreakdownInsight(groupID: newInsightGroupID, title: "OS Breakdown", breakdownKey: "systemVersion"), appID: appID) }
                                    ]
                                )
                            }
                        }
                    }
                }
            }
            .navigationBarTitle(appService.getSelectedApp()?.name ?? "–")
            .toolbar {
                ToolbarItem {
                    Button(insightCalculationService.timeIntervalDescription) {
                        withAnimation {
                            self.showDatePicker.toggle()
                        }
                    }
                }
            }

            if showDatePicker {
                Rectangle()
                    .fill(Color.grayColor.opacity(0.4))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onTapGesture {
                        withAnimation {
                            showDatePicker = false
                        }
                    }

                CardView {
                    InsightDataTimeIntervalPicker()
                        .padding()
                }
                .frame(maxHeight: 200)
                .padding()
                .transition(.move(edge: .bottom))
            }
        }
    }
}

extension UUID: Identifiable {
    public var id: UUID { return self }
}
