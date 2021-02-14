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
            }
            .padding()
        }
    }
}
