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
    let insightResultService: InsightResultService
        
    let updateService: UpateService
    let signalsService: SignalsService
    let lexiconService: LexiconService
    let oldappService: OldAppService
    let oldinsightService: OldInsightService
    let insightCalculationService: InsightCalculationService
    

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
            
                .environmentObject(updateService)
                .environmentObject(signalsService)
                .environmentObject(lexiconService)
                .environmentObject(oldappService)
                .environmentObject(oldinsightService)
                .environmentObject(insightCalculationService)
                .environmentObject(orgService)
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
        
        self.updateService = UpateService()
        self.signalsService = SignalsService(api: api)
        self.lexiconService = LexiconService(api: api)
        self.oldappService = OldAppService(api: api)
        self.oldinsightService = OldInsightService(api: api)
        self.insightCalculationService = InsightCalculationService(api: api)
        

        let configuration = TelemetryManagerConfiguration(appID: "79167A27-EBBF-4012-9974-160624E5D07B")
        configuration.sendSignalsInDebugConfiguration = true
        TelemetryManager.initialize(with: configuration)
        updateService.checkForUpdate()
    }
}
