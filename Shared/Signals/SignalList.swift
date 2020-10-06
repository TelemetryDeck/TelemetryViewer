//
//  SignalList.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 11.08.20.
//

import SwiftUI
import TelemetryClient

struct SignalList: View {
    @EnvironmentObject var telemetryManager: TelemetryManager
    @EnvironmentObject var api: APIRepresentative
    @Binding var isPresented: Bool
    var app: TelemetryApp
    
    var body: some View {
        
        let closeButton = Button("Close") {
            isPresented = false
        }
        .keyboardShortcut(.cancelAction)
        
        let list = List {
            if api.signals[app] == nil {
                ForEach(MockData.signals, id: \.self) { signal in
                    SignalView(signal: signal).redacted(reason: .placeholder)
                }
            } else {
                ForEach(api.signals[app]!, id: \.self) { signal in
                    SignalView(signal: signal)
                }
            }
        }
        .onAppear {
            api.getSignals(for: app)
            telemetryManager.send(TelemetrySignal.telemetryAppSignalsShown.rawValue, for: api.user?.email)
        }
        
        #if os(macOS)
        VStack {
            list
            closeButton
        }
            .frame(minWidth: 800, minHeight: 600)
            .padding()
        #else
        NavigationView {
            list
                .navigationTitle("Raw Signals")
                .navigationBarItems(trailing: closeButton)
        }
        #endif
    }
}
