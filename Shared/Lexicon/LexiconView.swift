//
//  LexiconView.swift
//  Telemetry Viewer (iOS)
//
//  Created by Daniel Jilg on 28.10.20.
//

import SwiftUI

struct LexiconView: View {
    @EnvironmentObject var api: APIRepresentative
    let app: TelemetryApp
    
    var body: some View {
        let list = List {
                Section(header: Text("Signal Types")) {
                    ForEach(api.lexiconSignalTypes[app] ?? []) { lexiconItem in
                        SignalTypeView(lexiconItem: lexiconItem)
                    }
                }
                .onAppear() {
                    api.getSignalTypes(for: app)
                    api.getPayloadKeys(for: app)
                }
                
                Section(header: Text("Payload Keys")) {
                    ForEach(api.lexiconPayloadKeys[app] ?? []) { lexiconItem in
                        PayloadKeyView(lexiconItem: lexiconItem)
                    }
                }
            }
        
        list
            .navigationTitle("Lexicon")
    }
}

struct LexiconView_Previews: PreviewProvider {
    static var previews: some View {
        let api = APIRepresentative()
        let app = TelemetryApp(id: UUID(), name: "anyApp", organization: [:])
        api.lexiconSignalTypes[app] = MockData.lexiconSignalTypes
        api.lexiconPayloadKeys[app] = MockData.lexiconPayloadKeys
        
        return LexiconView(app: app).environmentObject(api)
    }
}
