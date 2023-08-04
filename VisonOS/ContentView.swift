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
        ChartsExperiment(queryID: nil)
    }
}

#Preview {
    ContentView()
}
