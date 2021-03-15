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

    var appID: UUID
    private var app: TelemetryApp? { api.apps.first(where: { $0.id == appID }) }

    var body: some View {
        Group {
            if let app = app {
                ScrollView {
                    if api.signals[app] == nil {
                        ForEach(MockData.signals, id: \.self) { signal in
                            SignalView(signal: signal).redacted(reason: .placeholder)
                        }
                    } else {
                        ForEach(api.signals[app]!, id: \.self) { signal in
                            SignalView(signal: signal)
                        }

                        if api.signals[app]?.isEmpty != false {
                            Text("You haven't received any Signals yet. Once your app is sending out signals, you'll find here a list of the latest ones.\n\nHint: Usually, apps using the Telemetry Swift Client will only send out Signals if they are compiled in the Release build configuration. If your schema is in Debug mode, no signals will be sent.")
                                .font(.footnote)
                                .foregroundColor(.grayColor)
                        }
                    }
                }
                .padding(.horizontal)

            } else {
                Text("No App")
            }
        }
        .navigationTitle("Recent Signals")
        .onAppear {
            if let app = app {
                api.getSignals(for: app)
                TelemetryManager.shared.send(TelemetrySignal.telemetryAppSignalsShown.rawValue, for: api.user?.email)
            }
        }
    }
}
