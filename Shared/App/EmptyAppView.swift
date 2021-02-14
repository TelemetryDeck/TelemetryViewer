//
//  EmptyAppView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.01.21.
//

import SwiftUI

struct EmptyAppView: View {
    @EnvironmentObject var api: APIRepresentative
    @Binding var selectedInsightGroupID: UUID
    @Binding var sidebarSection: AppRootSidebarSection
    @Binding var sidebarShown: Bool

    var appID: UUID
    private var app: TelemetryApp? { api.apps.first(where: { $0.id == appID }) }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("A new App! Awesome!")
                .font(.title)
                .foregroundColor(.grayColor)
            Text("An app contains Insight Groups, which in turn contain Insights. Create your first Insight Group now.")
                .foregroundColor(.grayColor)

            Image(systemName: "square.grid.2x2.fill")
                .font(.system(size: 60))
                .foregroundColor(.grayColor)

            VStack {
                Button("Create First Insight Group") {
                    if let app = app {
                        api.create(insightGroupNamed: "New Insight Group", for: app) { result in
                            switch result {
                            case let .success(insightGroup):
                                selectedInsightGroupID = insightGroup.id
                                sidebarSection = .InsightGroupEditor
                                withAnimation { sidebarShown = true }
                            case let .failure(error):
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
                .buttonStyle(SmallPrimaryButtonStyle())

                Button("Open Editor Sidebar") {
                    withAnimation { sidebarShown = true }
                }
                .buttonStyle(SmallSecondaryButtonStyle())

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
        .navigationTitle(app?.name ?? "No Name")
    }
}
