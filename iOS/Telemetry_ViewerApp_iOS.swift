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
    @Environment(\.scenePhase) var scenePhase
    
    let api: APIClient
    let cacheLayer: CacheLayer
    let errors: ErrorService
    let orgService: OrgService
    let appService: AppService
    let groupService: GroupService
    let insightService: InsightService
    let insightResultService: InsightResultService
    let iconFinderService: IconFinderService
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
                .environmentObject(signalsService)
                .environmentObject(lexiconService)
                .environmentObject(orgService)
                .environmentObject(iconFinderService)
        }
        .onChange(of: scenePhase) { newScenePhase in
            if newScenePhase == .active {
                TelemetryManager.generateNewSession()
            }
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
        
        self.signalsService = SignalsService(api: api)
        self.lexiconService = LexiconService(api: api)
        
        self.iconFinderService = IconFinderService(api: api)
        
        let configuration = TelemetryManagerConfiguration(appID: "79167A27-EBBF-4012-9974-160624E5D07B")
        TelemetryManager.initialize(with: configuration)
        
        UserDefaults.standard.register(defaults: ["isTestingMode" : true])
    }
}
