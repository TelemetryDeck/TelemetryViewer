//
//  EmptyInsightGroupView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.01.21.
//

import SwiftUI
import TelemetryModels

struct EmptyInsightGroupView: View {
    @EnvironmentObject var api: APIRepresentative
    let selectedInsightGroupID: UUID

    var appID: UUID
    private var app: TelemetryApp? { api.apps.first(where: { $0.id == appID }) }

    private var insightGroup: InsightGroup? {
        guard let app = app else { return nil }
        return (api.insightGroups[app] ?? []).first(where: { $0.id == selectedInsightGroupID })
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("This Insight Group is Empty")
                .font(.title)
                .foregroundColor(.grayColor)
            Text("Insight Groups contain Insights, the basic building blocks of Telemetry, and belong to an app. Add your first Insight now.")
                .foregroundColor(.grayColor)

            Image(systemName: "app.fill")
                .font(.system(size: 60))
                .foregroundColor(.grayColor)

            #if os(macOS)
            Text("Create your first insight by clicking the + button in the toolbar and selecting an Insight template to create. After creating the insight, you can click to edit it.")
                .foregroundColor(.grayColor)
            #else
            Text("Create your first insight by tapping the Menu Button in the top right corner, tapping 'New Insight', and selecting an Insight template to create. After creating the insight, you can tap to edit it.")
                .foregroundColor(.grayColor)
            #endif

            Text("To read more about how to send signals from your app, read the documentation on setting up your app.")
                .foregroundColor(.grayColor)
                .font(.footnote)
                .padding(.vertical)
        }
    }
}
