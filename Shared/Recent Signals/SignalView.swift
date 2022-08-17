//
//  SignalView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 11.08.20.
//

import DataTransferObjects
import SwiftUI

struct SignalView: View {
    var signal: DTOv1.Signal
    let defaultPayloads = ["platform", "systemVersion", "majorSystemVersion", "majorMinorSystemVersion", "appVersion", "buildNumber", "isSimulator", "isDebug", "isTestFlight", "isAppStore", "modelName", "architecture", "operatingSystem", "targetEnvironment", "locale", "telemetryClientVersion"]

    @State private var showPayload: Bool = false

    var body: some View {
        let keys = signal.payload != nil ? Array(signal.payload!.keys) : []

        return List {
            Section(header: Text("Signal Data")) {
                VStack(alignment: .leading) {
                    Text("Received at").bold()
                    HStack {
                        Text(signal.receivedAt, style: .date)
                        Text(signal.receivedAt, style: .time)
                    }
                }

                KVView(key: "User", value: signal.clientUser)

                signal.sessionID.map {
                    KVView(key: "Session", value: String($0))
                }

                signal.count.map {
                    KVView(key: "Count", value: String($0))
                }
            }
            
            if !(signal.payload?.filter { !defaultPayloads.contains($0.key) }.isEmpty ?? true) {
                Section(header: Text("Custom Payload")) {
                    ForEach(keys.sorted(), id: \.self) { payloadKey in
                        if !defaultPayloads.contains(payloadKey) {
                            signal.payload?[payloadKey].map {
                                KVView(key: payloadKey, value: $0)
                            }
                        }
                    }
                }
            }

            Section(header: Text("Default Payload")) {
                ForEach(keys.sorted(), id: \.self) { payloadKey in
                    if defaultPayloads.contains(payloadKey) {
                        signal.payload?[payloadKey].map {
                            KVView(key: payloadKey, value: $0)
                        }
                    }
                }
            }
        }
        .navigationTitle("\(signal.type)")
    }
}

struct SignalView_Previews: PreviewProvider {
    static var previews: some View {
        let signal: DTOv1.Signal = .init(
            receivedAt: Date(),
            clientUser: UUID().uuidString,
            type: "ExampleSignal",
            payload: [
                "appVersion": "1.0",
                "systemVersion": "14.0",
            ], isTestMode: false
        )
        SignalView(signal: signal)
    }
}

struct KVView: View {
    let key: String
    let value: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(key).bold()
            Text(value)
        }
    }
}
