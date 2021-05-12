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
    let api: APIRepresentative
    let appUpdater: AppUpdater
    let signalsService: SignalsService

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(api)
                .environmentObject(appUpdater)
                .environmentObject(signalsService)
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

        Settings {
            MacSettingsView().environmentObject(api)
        }
    }

    init() {
        self.api = APIRepresentative()
        self.appUpdater = AppUpdater()
        self.signalsService = SignalsService(api: api)

        let configuration = TelemetryManagerConfiguration(appID: "79167A27-EBBF-4012-9974-160624E5D07B")
        TelemetryManager.initialize(with: configuration)
        appUpdater.checkForUpdate()
    }
}
