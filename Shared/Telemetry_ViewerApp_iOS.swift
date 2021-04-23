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
    let api = APIRepresentative()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(api)
        }
        .onChange(of: scenePhase) { newScenePhase in
            if newScenePhase == .active {
                TelemetryManager.generateNewSession()
            }
        }
    }

    init() {
        let configuration = TelemetryManagerConfiguration(appID: "79167A27-EBBF-4012-9974-160624E5D07B")
        TelemetryManager.initialize(with: configuration)
    }
}
