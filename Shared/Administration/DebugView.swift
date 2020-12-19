//
//  DebugView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 18.12.20.
//

import SwiftUI

struct DebugView: View {
    @EnvironmentObject var api: APIRepresentative

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {

                Group {
                    CustomSection(header: Text("timeWindowBeginning"), summary: EmptyView(), footer: EmptyView()) {
                        if let timeWindowBeginning = api.timeWindowBeginning {
                            Text(timeWindowBeginning, style: .date)
                        } else {
                            Text("Default")
                        }
                    }

                    CustomSection(header: Text("timeWindowEnd"), summary: EmptyView(), footer: EmptyView()) {
                        if let timeWindowEnd = api.timeWindowEnd {
                            Text(timeWindowEnd, style: .date)
                        } else {
                            Text("Default")
                        }
                    }

                    CustomSection(header: Text("requests"), summary: Text("\(api.requests.count)"), footer: EmptyView(), startCollapsed: true) {
                        Text("\(api.requests.debugDescription)")
                    }

                    CustomSection(header: Text("user"), summary: Text("\(api.user?.email ?? "no mail")"), footer: EmptyView(), startCollapsed: true) {
                        Text("\(api.user.debugDescription)")
                    }

                    CustomSection(header: Text("userNotLoggedIn"), summary: Text("\(api.userNotLoggedIn ? "True" : "False")"), footer: EmptyView(), startCollapsed: true) {
                        Text("\(api.userNotLoggedIn ? "True" : "False")")
                    }
                }


                Group {
                    CustomSection(header: Text("apps"), summary: Text("\(api.apps.count)"), footer: EmptyView(), startCollapsed: true) {
                        Text("\(api.apps.debugDescription)")
                    }

                    CustomSection(header: Text("signals"), summary: Text("\(api.signals.count)"), footer: EmptyView(), startCollapsed: true) {
                        Text("\(api.signals.debugDescription)")
                    }

                    CustomSection(header: Text("insightGroups"), summary: Text("\(api.insightGroups.count)"), footer: EmptyView(), startCollapsed: true) {
                        Text("\(api.insightGroups.debugDescription)")
                    }

                    CustomSection(header: Text("insightData"), summary: Text("\(api.insightData.count)"), footer: EmptyView(), startCollapsed: true) {
                        Text("\(api.insightData.debugDescription)")
                    }
                }

                Group {
                    CustomSection(header: Text("Get InsightData"), summary: EmptyView(), footer: EmptyView(), startCollapsed: true) {
                        Button("Get Insightdata") {
                            let app = TelemetryApp(id: UUID(uuidString: "B97579B6-FFB8-4AC5-AAA7-DA5796CC5DCE")!, name: "Libi", organization: [:])
                            let insightGroup = InsightGroup(id: UUID(uuidString: "D0DAB332-3C26-46BE-98EF-D828587292D0")!, title: "Users")
                            let insight = Insight(id: UUID(uuidString: "46008B3A-8BAB-4E8F-BB3E-E314E38FB768")!, group: [:], order: nil, title: "", subtitle: nil, signalType: nil, uniqueUser: false, filters: [:], rollingWindowSize: 0, breakdownKey: nil, groupBy: nil, displayMode: .barChart, isExpanded: false)

                            DispatchQueue.global().async {
                                while true {
                                    api.getInsightData(for: insight, in: insightGroup, in: app)
                                    sleep(1)
                                }
                            }

                        }
                    }
                }

            }
            .padding()
        }
    }
}
