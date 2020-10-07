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
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(api)
                .accentColor(Color("Torange"))
        }
    }
    
    init() {
        let configuration = TelemetryManagerConfiguration(appID: "79167A27-EBBF-4012-9974-160624E5D07B")
        TelemetryManager.initialize(with: configuration)
        TelemetryManager.shared.send(TelemetrySignal.appLaunchedRegularly.rawValue, for: api.user?.email)
    }
}
