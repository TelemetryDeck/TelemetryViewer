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
    let api: APIClient
    let cacheLayer: CacheLayer
    let errors: ErrorService
    let orgService: OrgService
    let appService: AppService
    let groupService: GroupService
    let insightService: InsightService
    let iconFinderService: IconFinderService
    let updateService: UpdateService
    let signalsService: SignalsService
    let lexiconService: LexiconService
    let queryService: QueryService

    var body: some Scene {
        WindowGroup {
            RootView()
                .onOpenURL(perform: { url in
                    handleIncomingURL(url: url)
                })
                .environmentObject(api)
                .environmentObject(errors)
                .environmentObject(orgService)
                .environmentObject(appService)
                .environmentObject(groupService)
                .environmentObject(insightService)
                .environmentObject(iconFinderService)
                .environmentObject(updateService)
                .environmentObject(signalsService)
                .environmentObject(lexiconService)
                .environmentObject(queryService)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
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
        self.appService = AppService(api: api, errors: errors)
        self.groupService = GroupService(api: api, errors: errors)
        self.insightService = InsightService(api: api, errors: errors)
        self.iconFinderService = IconFinderService(api: api)
        self.updateService = UpdateService()
        self.signalsService = SignalsService(api: api)
        self.lexiconService = LexiconService(api: api)
        self.queryService = QueryService(api: api, errors: errors)

        let configuration = TelemetryManagerConfiguration(appID: "79167A27-EBBF-4012-9974-160624E5D07B")
        TelemetryManager.initialize(with: configuration)
        updateService.checkForUpdate()

        UserDefaults.standard.register(defaults: ["isTestingMode": true])
    }

    // telemetryviewer://login/<bearertoken>
    func handleIncomingURL(url: URL) {
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host,
              let path = components.path
        else { return }

        if host == "login" {
            guard let bearerToken = path.split(separator: "/", maxSplits: 1).last else { return }
            api.login(bearerToken: String(bearerToken))
        }
    }
}
