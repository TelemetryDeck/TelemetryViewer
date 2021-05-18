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
    let api: APIRepresentative
    let signalsService: SignalsService
    let lexiconService: LexiconService
    let insightCalculationService: InsightCalculationService

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(api)
                .environmentObject(signalsService)
                .environmentObject(lexiconService)
                .environmentObject(insightCalculationService)
        }
        .onChange(of: scenePhase) { newScenePhase in
            if newScenePhase == .active {
                TelemetryManager.generateNewSession()
            }
        }
    }

    init() {
        self.api = APIRepresentative()
        self.signalsService = SignalsService(api: api)
        self.lexiconService = LexiconService(api: api)
        self.insightCalculationService = InsightCalculationService(api: api)
        
        let configuration = TelemetryManagerConfiguration(appID: "79167A27-EBBF-4012-9974-160624E5D07B")
        TelemetryManager.initialize(with: configuration)
    }
}
