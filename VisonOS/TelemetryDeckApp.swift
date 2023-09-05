//
//  TelemetryDeckApp.swift
//  TelemetryDeck
//
//  Created by Daniel Jilg on 04.08.23.
//

import SwiftUI
import TelemetryClient

@main
struct TelemetryDeckApp: App {
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    @Environment(\.openWindow) private var openWindow
    
    var body: some Scene {
        WindowGroup {
                    TabView {
                        ChartsExperiment()
                            .tabItem {
                                Image(systemName: "person.crop.circle")
                                Text("Users")
                            }
            
                        ChartsExperiment()
                            .tabItem {
                                Image(systemName: "person.crop.circle")
                                Text("Versions")
                            }
            
                        ChartsExperiment()
                            .tabItem {
                                Image(systemName: "person.crop.circle")
                                Text("Features")
                            }
                        ChartsExperiment()
                            .tabItem {
                                Image(systemName: "person.crop.circle")
                                Text("Platforms}")
                            }
            
                        ChartsExperiment()
                            .tabItem {
                                Image(systemName: "person.crop.circle")
                                Text("Widgets")
                            }
            
                        ChartsExperiment()
                            .tabItem {
                                Image(systemName: "person.crop.circle")
                                Text("Experimental Test Group")
                            }
                        ChartsExperiment()
                            .tabItem {
                                Image(systemName: "person.crop.circle")
                                Text("Documentation Test Group")
                            }
            
                        ChartsExperiment()
                            .tabItem {
                                Image(systemName: "person.crop.circle")
                                Text("Charts")
                            }
            
                        ChartsExperiment()
                            .tabItem {
                                Image(systemName: "person.crop.circle")
                                Text("Funnels")
                            }
                        ChartsExperiment()
                            .tabItem {
                                Image(systemName: "person.crop.circle")
                                Text("A/B Tests")
                            }
            
                        ChartsExperiment()
                            .tabItem {
                                Image(systemName: "person.crop.circle")
                                Text("Versions")
                            }
            
                        ChartsExperiment()
                            .tabItem {
                                Image(systemName: "person.crop.circle")
                                Text("Features")
                            }
                        
                    }
        }
        .windowStyle(.plain)
        
//        WindowGroup(id: "daily-users") {
//            ChartsExperiment(queryID: "daily-users")
//        }
//        
//        WindowGroup(id: "monthly-signals") {
//            ChartsExperiment(queryID: "monthly-signals")
//        }
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }

    }
    
    
    init() {
        let configuration = TelemetryManagerConfiguration(appID: "79167A27-EBBF-4012-9974-160624E5D07B")
        TelemetryManager.initialize(with: configuration)

    }
}
