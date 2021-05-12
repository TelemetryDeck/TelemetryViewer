//
//  SignalView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 11.08.20.
//

import SwiftUI

struct SignalView: View {
    var signal: DTO.Signal

    @State private var showPayload: Bool = false

    var columns = [
        GridItem(.fixed(50)),
        GridItem(.fixed(150)),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var payloadColumns = [GridItem(.flexible())]

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
                    KVView(key: "Session", value: $0)
                }
                
                signal.count.map {
                    KVView(key: "Count", value: String($0))
                }
            }

            Section(header: Text("Payload")) {
                ForEach(keys.sorted(), id: \.self) { payloadKey in
                    signal.payload?[payloadKey].map {
                        KVView(key: payloadKey, value: $0)
                    }
                }
            }
        }
        .navigationTitle("\(signal.type) \(signal.receivedAt)")
    }
}

struct SignalView_Previews: PreviewProvider {
    static var previews: some View {
        let signal: DTO.Signal = .init(
            receivedAt: Date(),
            clientUser: UUID().uuidString,
            type: "ExampleSignal",
            payload: [
                "appVersion": "1.0",
                "systemVersion": "14.0",
            ]
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
