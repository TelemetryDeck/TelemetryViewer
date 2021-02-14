//
//  InsightGroupList.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.09.20.
//

import SwiftUI
import TelemetryClient

struct InsightGroupList: View {
    @Binding var sidebarSection: AppRootSidebarSection
    @Binding var sidebarShown: Bool
    @Binding var selectedInsightID: UUID?
    @EnvironmentObject var api: APIRepresentative
    var app: TelemetryApp
    var insightGroupID: UUID

    let refreshTimer = Timer.publish(
        every: 5 * 60, // 5 minutes
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {
        Group {
            if let insightGroup = (api.insightGroups[app] ?? []).first(where: { $0.id == insightGroupID }), !insightGroup.insights.isEmpty {
                ScrollView(.vertical) {
                    InsightsGrid(app: app, insightGroup: insightGroup, selectedInsightID: $selectedInsightID)
                    Spacer()

                    Button("Documentation: Sending Signals") {
                        #if os(macOS)
                            NSWorkspace.shared.open(URL(string: "https://apptelemetry.io/pages/quickstart.html")!)
                        #else
                            UIApplication.shared.open(URL(string: "https://apptelemetry.io/pages/quickstart.html")!)
                        #endif
                    }
                    .font(.footnote)
                    .foregroundColor(.grayColor)
                    .padding(.bottom)
                }
                .navigationTitle(insightGroup.title)
            } else {
                EmptyInsightGroupView(
                    selectedInsightGroupID: insightGroupID,
                    selectedInsightID: $selectedInsightID,
                    sidebarSection: $sidebarSection,
                    sidebarShown: $sidebarShown,
                    appID: app.id
                )
                .frame(maxWidth: 400)
                .padding()
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
