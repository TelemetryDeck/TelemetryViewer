//
//  Telemetry_ViewerApp.swift
//  Shared
//
//  Created by Daniel Jilg on 30.07.20.
//

import SwiftUI
import TelemetryClient
import TelemetryDeckClient

@main
struct Telemetry_ViewerApp: App {
    let api: APIClient
    let cacheLayer: CacheLayer
    let errors: ErrorService
    let orgService: OrgService
    let appService: AppService
    let groupService: GroupService
    let insightService: InsightService
    let insightResultService: InsightResultService
    let iconFinderService: IconFinderService
    let updateService: UpdateService
    let signalsService: SignalsService
    let lexiconService: LexiconService

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(api)
                .environmentObject(errors)
                .environmentObject(orgService)
                .environmentObject(appService)
                .environmentObject(groupService)
                .environmentObject(insightService)
                .environmentObject(insightResultService)
                .environmentObject(iconFinderService)
                .environmentObject(updateService)
                .environmentObject(signalsService)
                .environmentObject(lexiconService)
        }
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle())
        .commands {
            SidebarCommands()

            CommandGroup(replacing: CommandGroupPlacement.help) {
                Button("Online Docs for Telemetry") {
                    NSWorkspace.shared.open(URL(string: "https://telemetrydeck.com/pages/docs.html")!)
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
                .environmentObject(orgService)
        }
    }

    init() {
        self.api = APIClient()
        self.cacheLayer = CacheLayer()
        self.errors = ErrorService()

        self.orgService = OrgService(api: api, cache: cacheLayer, errors: errors)
        self.appService = AppService(api: api, cache: cacheLayer, errors: errors)
        self.groupService = GroupService(api: api, cache: cacheLayer, errors: errors)
        self.insightService = InsightService(api: api, cache: cacheLayer, errors: errors)
        self.insightResultService = InsightResultService(api: api, cache: cacheLayer, errors: errors)
        self.iconFinderService = IconFinderService(api: api)
        self.updateService = UpdateService()
        self.signalsService = SignalsService(api: api)
        self.lexiconService = LexiconService(api: api)

        let configuration = TelemetryManagerConfiguration(appID: "79167A27-EBBF-4012-9974-160624E5D07B")
        TelemetryManager.initialize(with: configuration)
        updateService.checkForUpdate()

        UserDefaults.standard.register(defaults: ["isTestingMode": true])
    }
}
