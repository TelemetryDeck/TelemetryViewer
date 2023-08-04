//
//  TelemetryDeckApp.swift
//  TelemetryDeck
//
//  Created by Daniel Jilg on 04.08.23.
//

import SwiftUI

@main
struct TelemetryDeckApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
