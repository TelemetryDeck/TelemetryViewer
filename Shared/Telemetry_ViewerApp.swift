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
    let telemetryManager: TelemetryManager = TelemetryManager(configuration: TelemetryManagerConfiguration(appID: "79167A27-EBBF-4012-9974-160624E5D07B"))
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(api)
                .environmentObject(telemetryManager)
                .accentColor(Color("Torange"))
        }
    }
    
    init() {
        telemetryManager.send(TelemetrySignal.appLaunchedRegularly.rawValue, for: api.user?.email)
    }
}
