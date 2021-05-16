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
    let updateService: UpateService
    let signalsService: SignalsService
    let lexiconService: LexiconService

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(api)
                .environmentObject(updateService)
                .environmentObject(signalsService)
                .environmentObject(lexiconService)
        }
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle())
        .commands {
            SidebarCommands()

            CommandGroup(replacing: CommandGroupPlacement.help) {
                Button("Online Docs for Telemetry") {
                    NSWorkspace.shared.open(URL(string: "https://apptelemetry.io/pages/docs.html")!)
                }
            }

            CommandGroup(after: CommandGroupPlacement.appSettings) {
                Button("Check for Update") {
                    updateService.checkForUpdate()
                }
            }
        }

        Settings {
            MacSettingsView()
                .environmentObject(api)
                .environmentObject(updateService)
        }
    }

    init() {
        self.api = APIRepresentative()
        self.updateService = UpateService()
        self.signalsService = SignalsService(api: api)
        self.lexiconService = LexiconService(api: api)

        let configuration = TelemetryManagerConfiguration(appID: "79167A27-EBBF-4012-9974-160624E5D07B")
        TelemetryManager.initialize(with: configuration)
        updateService.checkForUpdate()
    }
}
