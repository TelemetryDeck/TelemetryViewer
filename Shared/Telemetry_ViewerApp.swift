//
//  Telemetry_ViewerApp.swift
//  Shared
//
//  Created by Daniel Jilg on 30.07.20.
//

import SwiftUI

@main
struct Telemetry_ViewerApp: App {
    let api = APIRepresentative()
    
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(api)
        }
    }
    
    init() {
        TelemetryManager().send(.appLaunchedRegularly, for: api.user?.email)
    }
}
