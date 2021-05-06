//
//  EmptyAppView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.01.21.
//

import SwiftUI

struct EmptyAppView: View {
    @EnvironmentObject var api: APIRepresentative

    let appID: UUID
    private var app: TelemetryApp? { api.apps.first(where: { $0.id == appID }) }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("A new App! Awesome!")
                .font(.title)
                .foregroundColor(.grayColor)

            Text("An app contains Insight Groups, which in turn contain Insights.")
                .foregroundColor(.grayColor)

            Image(systemName: "square.grid.2x2.fill")
                .font(.system(size: 60))
                .foregroundColor(.grayColor)

            #if os(macOS)
            Text("Create your first Insight Group now by clicking the New Group button in the top left.")
                .foregroundColor(.grayColor)
            #else
            Text("Create your first Insight Group now by tapping the Menu button in the top right corner, then tapping 'New Group'.")
                .foregroundColor(.grayColor)
            #endif

            Button("Documentation: Sending Signals") {
                #if os(macOS)
                    NSWorkspace.shared.open(URL(string: "https://apptelemetry.io/pages/quickstart.html")!)
                #else
                    UIApplication.shared.open(URL(string: "https://apptelemetry.io/pages/quickstart.html")!)
                #endif
            }
            .buttonStyle(SmallSecondaryButtonStyle())

            Spacer()
        }
        .navigationTitle(app?.name ?? "No Name")
    }
}
