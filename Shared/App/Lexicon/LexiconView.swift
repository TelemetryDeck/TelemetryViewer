//
//  LexiconView.swift
//  Telemetry Viewer (iOS)
//
//  Created by Daniel Jilg on 28.10.20.
//

import SwiftUI
import TelemetryModels

struct LexiconView: View {
    @EnvironmentObject var api: APIRepresentative

    let appID: UUID
    private var app: TelemetryApp? { api.apps.first(where: { $0.id == appID }) }

    var body: some View {
        if let app = app {
            let list = List {
                Section(header: Text("Signal Types")) {
                    ForEach(api.lexiconSignalTypes[app] ?? []) { lexiconItem in
                        SignalTypeView(lexiconItem: lexiconItem)
                    }

                    if api.lexiconSignalTypes[app]?.isEmpty != false {
                        Text("Once you've received a few Signals, this list will contain all Signal Types known to Telemetry.")
                            .font(.footnote)
                            .foregroundColor(.grayColor)
                    }
                }

                Section(header: Text("Payload Keys")) {
                    ForEach(api.lexiconPayloadKeys[app] ?? []) { lexiconItem in
                        PayloadKeyView(lexiconItem: lexiconItem)
                    }

                    if api.lexiconPayloadKeys[app]?.isEmpty != false {
                        Text("Once you've received a few Signals with payload metadata, this list will contain all available payload keys known to Telemetry.")
                            .font(.footnote)
                            .foregroundColor(.grayColor)
                    }
                }
            }

            list
                .listRowBackground(Color.clear)
                .navigationTitle("Lexicon")
                .onAppear {
                    api.getSignalTypes(for: app)
                    api.getPayloadKeys(for: app)
                }
        } else {
            Text("No App")
        }
    }
}

//
// struct LexiconView_Previews: PreviewProvider {
//    static var previews: some View {
//        let api = APIRepresentative()
//        let app = TelemetryApp(id: UUID(), name: "anyApp", organization: [:])
//        api.lexiconSignalTypes[app] = MockData.lexiconSignalTypes
//        api.lexiconPayloadKeys[app] = MockData.lexiconPayloadKeys
//
//        return LexiconView(app: app).environmentObject(api)
//    }
// }
