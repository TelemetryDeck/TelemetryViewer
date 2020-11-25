//
//  InsightGroupList.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.09.20.
//

import SwiftUI
import TelemetryClient

struct InsightGroupList: View {

    @Binding var sidebarElement: SidebarElement?
    @EnvironmentObject var api: APIRepresentative
    var app: TelemetryApp
    var insightGroupID: UUID
    
    let refreshTimer = Timer.publish(
        every: 5*60, // 5 minutes
        on: .main,
        in: .common
    ).autoconnect()
    
    var body: some View {
        if let insightGroup = (api.insightGroups[app] ?? []).first(where: { $0.id == insightGroupID }) {
            
            ScrollView(.vertical) {
                
                if insightGroup.insights.isEmpty {
                    VStack {
                        Text("This Insight Group is Empty")
                        Button("Delete it") {
                            api.delete(insightGroup: insightGroup, in: app)
                        }
                    }
                } else {
                    InsightsGrid(app: app, insightGroup: insightGroup, sidebarElement: $sidebarElement)
                }
                
                Spacer()
                
                Text("Insights will automatically refresh once a minute")
                    .font(.footnote)
                    .foregroundColor(.grayColor)
            }
            
            .onAppear {
                api.getInsightGroups(for: app)
                TelemetryManager.shared.send(TelemetrySignal.telemetryAppInsightsShown.rawValue, for: api.user?.email)
            }
            .onReceive(refreshTimer) { _ in
                api.getInsightGroups(for: app)
                TelemetryManager.shared.send(TelemetrySignal.telemetryAppInsightsRefreshed.rawValue, for: api.user?.email)
            }
            .navigationTitle(insightGroup.title)
        }
    }
}
