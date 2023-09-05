//
//  ContentView.swift
//  TelemetryDeck
//
//  Created by Daniel Jilg on 04.08.23.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @State private var showImmersiveSpace = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        TabView {
           Text("RED")
             .tabItem {
                Image(systemName: "phone.fill")
                Text("First Tab")
           }
           Text("BLEU")
             .tabItem {
                Image(systemName: "tv.fill")
                Text("Second Tab")
          }
        }
        
        
//        TabView {
//            ChartsExperiment()
//                .tabItem {
//                    Image(systemName: "person.crop.circle")
//                    Text("Users")
//                }
//            
//            ChartsExperiment()
//                .tabItem {
//                    Image(systemName: "person.crop.circle")
//                    Text("Versions")
//                }
//            
//            ChartsExperiment()
//                .tabItem {
//                    Image(systemName: "person.crop.circle")
//                    Text("Features")
//                }
//        }
//        
    }
}
