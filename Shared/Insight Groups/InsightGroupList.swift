//
//  InsightGroupList.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.09.20.
//

import SwiftUI
import TelemetryClient

struct InsightGroupList: View {

    @Binding var selectedInsightID: UUID?
    @EnvironmentObject var api: APIRepresentative
    var app: TelemetryApp
    var insightGroupID: UUID
    
    let refreshTimer = Timer.publish(
        every: 5*60, // 5 minutes
        on: .main,
        in: .common
    ).autoconnect()
    
    var body: some View {
        Group {
            if let insightGroup = (api.insightGroups[app] ?? []).first(where: { $0.id == insightGroupID }), !insightGroup.insights.isEmpty {

                ScrollView(.vertical) {
                    InsightsGrid(app: app, insightGroup: insightGroup, selectedInsightID: $selectedInsightID)
                    Spacer()

                    Text("Insights will automatically refresh every 5 minutes")
                        .font(.footnote)
                        .foregroundColor(.grayColor)
                        .padding(.bottom)
                }
                .navigationTitle(insightGroup.title)
            } else {

                VStack(spacing: 20) {

                    Image("arrow-left-right")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 300)
                        .rotationEffect(.degrees(-30))
                    Text("This Insight Group is Empty. You can add Insights to your Insights Group by opening the sidebar 􀏛 and selecting the insight group section 􀚈")
                        .foregroundColor(.grayColor)
                }
                .frame(maxWidth: 400)
            }
        }


        .onAppear {
            api.getInsightGroups(for: app)
            TelemetryManager.shared.send(TelemetrySignal.telemetryAppInsightsShown.rawValue, for: api.user?.email)
        }
        .onReceive(refreshTimer) { _ in
            api.getInsightGroups(for: app)
            TelemetryManager.shared.send(TelemetrySignal.telemetryAppInsightsRefreshed.rawValue, for: api.user?.email)
        }
    }
}
