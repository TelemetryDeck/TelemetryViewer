//
//  SignalList.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 11.08.20.
//

import SwiftUI
import TelemetryClient

struct SignalList: View {
    @EnvironmentObject var api: APIRepresentative
    var app: TelemetryApp
    
    var body: some View {
    
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
            TelemetryManager.shared.send(TelemetrySignal.telemetryAppSignalsShown.rawValue, for: api.user?.email)
        }
        
        list
            .navigationTitle("Raw Signals")

    }
}
