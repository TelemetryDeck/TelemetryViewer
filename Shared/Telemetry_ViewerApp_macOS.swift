//
//  Telemetry_ViewerApp.swift
//  Shared
//
//  Created by Daniel Jilg on 30.07.20.
//

import SwiftUI
import TelemetryClient

@main
struct Telemetry_ViewerApp: App {
    let api = APIRepresentative()
    let appUpdater = AppUpdater()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(api)
                .environmentObject(appUpdater)
        }
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle())
        .commands {
            SidebarCommands()
            CommandGroup(replacing: CommandGroupPlacement.help) {
                Button("Online Docs for Telemetry") {
                    NSWorkspace.shared.open(URL(string: "https://apptelemetry.io/pages/docs.html")!)
                }
            }
        }
    }

    init() {
        let configuration = TelemetryManagerConfiguration(appID: "79167A27-EBBF-4012-9974-160624E5D07B")
        TelemetryManager.initialize(with: configuration)
        appUpdater.checkForUpdate()
    }
}
