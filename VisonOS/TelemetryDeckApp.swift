//
//  TelemetryDeckApp.swift
//  TelemetryDeck
//
//  Created by Daniel Jilg on 04.08.23.
//

import SwiftUI

@main
struct TelemetryDeckApp: App {
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    @Environment(\.openWindow) private var openWindow
    
    var body: some Scene {
        WindowGroup {
            ChartsExperiment(queryID: nil)
                .onAppear {
                    openWindow(id: "daily-users")
                    openWindow(id: "monthly-signals")
                }
        }
        
        WindowGroup(id: "daily-users") {
            ChartsExperiment(queryID: "daily-users")
        }
        
        WindowGroup(id: "monthly-signals") {
            ChartsExperiment(queryID: "monthly-signals")
        }
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
