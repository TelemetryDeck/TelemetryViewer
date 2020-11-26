//
//  InsightEditor.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 26.11.20.
//

import SwiftUI


struct InsightEditor: View {
    let appID: UUID
    private var app: TelemetryApp? { api.apps.first(where: { $0.id == appID }) }
    @Binding var selectedInsightGroupID: UUID
    @Binding var selectedInsightID: UUID?
    @EnvironmentObject var api: APIRepresentative

    var insightGroup: InsightGroup? {
        guard let app = app else { return nil }
        let insightGroup = api.insightGroups[app]?.first(where: { $0.id == selectedInsightGroupID })
        return insightGroup
    }

    var insight: Insight? {
        insightGroup?.insights.first { $0.id == selectedInsightID }
    }

    var insightDTO: InsightDataTransferObject? {
        selectedInsightID != nil ? api.insightData[selectedInsightID!] : nil
    }

    var padding: CGFloat? {
        #if os(macOS)
        return nil
        #else
        return 0
        #endif
    }


    var body: some View {
        if let insightDTO = insightDTO, let insightGroup = insightGroup, let insight = insight, let app = app {
            Form {
                Section(header: Text("Delete")) {
                    Button("Delete this Insight") {
                        print("Delete")
                        api.delete(insight: insight, in: insightGroup, in: app)
                    }
                }
            }
            .padding(.horizontal, padding)
        } else {
            Text("No Insight Selected").foregroundColor(.grayColor)
        }
    }
}
