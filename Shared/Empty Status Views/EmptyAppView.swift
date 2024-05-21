//
//  EmptyAppView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.01.21.
//

import SwiftUI
import DataTransferObjects

struct EmptyAppView: View {
    @EnvironmentObject var appService: AppService

    let appID: UUID
    private var app: AppInfo? { appService.app(withID: appID) }

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
            Text("Create your first Insight Group now by tapping 'New Insight Group' in the toolbar.")
                .foregroundColor(.grayColor)
            #endif

            Button("Documentation: Sending Signals") {
                URL(string: "https://telemetrydeck.com/pages/quickstart.html")?.open()
            }
            .buttonStyle(SmallSecondaryButtonStyle())

            Spacer()
        }
        .navigationTitle(app?.name ?? "No Name")
    }
}
