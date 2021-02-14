//
//  EmptyInsightGroupView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.01.21.
//

import SwiftUI

struct EmptyInsightGroupView: View {
    @EnvironmentObject var api: APIRepresentative
    var selectedInsightGroupID: UUID
    @Binding var selectedInsightID: UUID?
    @Binding var sidebarSection: AppRootSidebarSection
    @Binding var sidebarShown: Bool

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

            VStack {
                Button("Create First Insight") {
                    if let app = app, let insightGroup = insightGroup {
                        let definitionRequestBody = InsightDefinitionRequestBody.new(groupID: selectedInsightGroupID)

                        api.create(insightWith: definitionRequestBody, in: insightGroup, for: app) { result in
                            switch result {
                            case let .success(insightDTO):
                                selectedInsightID = insightDTO.id
                                sidebarSection = .InsightEditor
                            case let .failure(error):
                                print(error)
                            }
                        }
                    }
                }
                .buttonStyle(SmallPrimaryButtonStyle())

                Button("Open Editor Sidebar") {
                    withAnimation { sidebarShown = true }
                }
                .buttonStyle(SmallSecondaryButtonStyle())

                Text("To read more about how to send signals from your app, read the documentation on setting up your app.")
                    .foregroundColor(.grayColor)
                    .font(.footnote)
                    .padding(.vertical)

                Button("Documentation: Sending Signals") {
                    #if os(macOS)
                        NSWorkspace.shared.open(URL(string: "https://apptelemetry.io/pages/quickstart.html")!)
                    #else
                        UIApplication.shared.open(URL(string: "https://apptelemetry.io/pages/quickstart.html")!)
                    #endif
                }
                .buttonStyle(SmallSecondaryButtonStyle())
            }
            Spacer()
        }
    }
}
