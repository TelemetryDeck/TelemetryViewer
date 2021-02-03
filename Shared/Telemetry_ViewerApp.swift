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

    #if os(macOS)
    let appUpdater = AppUpdater()
    #endif
    
    var body: some Scene {
        WindowGroup {
            #if os(macOS)
            RootView()
                .environmentObject(api)
                .environmentObject(appUpdater)
            #else
            RootView()
                .environmentObject(api)
            #endif

        }
        .commands {
            SidebarCommands()
            CommandGroup(replacing: CommandGroupPlacement.help) {
                Button("Online Docs for Telemetry") {
                    #if os(macOS)
                    NSWorkspace.shared.open(URL(string: "https://apptelemetry.io/pages/docs.html")!)
                    #else
                    UIApplication.shared.open(URL(string: "https://apptelemetry.io/pages/docs.html")!)
                    #endif
                }
            }
        }
    }
    
    init() {
        let configuration = TelemetryManagerConfiguration(appID: "79167A27-EBBF-4012-9974-160624E5D07B")
        TelemetryManager.initialize(with: configuration)

        #if os(macOS)
        appUpdater.checkForUpdate()
        #endif
    }
}

enum URLAction: String {
    case registerUserToOrg
}

extension URL {
    var isDeeplink: Bool {
        return scheme == "telemetryviewer"
    }
    
    var urlAction: URLAction? {
        guard isDeeplink else { return nil }
        
        switch host {
        case URLAction.registerUserToOrg.rawValue: return .registerUserToOrg
        default: return nil
        }
    }
}
