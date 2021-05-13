//
//  LexiconView.swift
//  Telemetry Viewer (iOS)
//
//  Created by Daniel Jilg on 28.10.20.
//

import SwiftUI
import TelemetryClient

struct LexiconView: View {
    @EnvironmentObject var lexiconService: LexiconService

    @State private var sortKey: LexiconService.LexiconSortKey = .signalCount

    let appID: UUID

    var body: some View {
        let list = List {
            Section(header: HStack {
                Button {
                    withAnimation {
                        sortKey = .type
                    }
                } label: {
                    Label("Signal Type", systemImage: sortKey == .type ? "arrowtriangle.down.fill" : "circle")
                }

                Spacer()
                
                Button {
                    withAnimation {
                        sortKey = .signalCount
                    }
                } label: {
                    Label("Signals", systemImage: sortKey == .signalCount ? "arrowtriangle.down.fill" : "circle")
                }
                
                Button {
                    withAnimation {
                        sortKey = .userCount
                    }
                } label: {
                    Label("Users", systemImage: sortKey == .userCount ? "arrowtriangle.down.fill" : "circle")
                }
                
                Button {
                    withAnimation {
                        sortKey = .sessionCount
                    }
                } label: {
                    Label("Sessions", systemImage: sortKey == .sessionCount ? "arrowtriangle.down.fill" : "circle")
                }
            }, footer:
            Text("This list contains all Signal Types seen by to AppTelemetry in the last month.")
                .font(.footnote)
                .foregroundColor(.grayColor)
                .multilineTextAlignment(.center)) {
                ForEach(lexiconService.signalTypes(for: appID, sortedBy: sortKey)) { lexiconItem in
                    SignalTypeView(lexiconItem: lexiconItem)
                }
            }

            Section(header: Text("Payload Keys"), footer:
                Text("This list contains all available payload keys known to AppTelemetry.")
                    .font(.footnote)
                    .foregroundColor(.grayColor)
                    .multilineTextAlignment(.center)) {
                ForEach(lexiconService.payloadKeys(for: appID)) { lexiconItem in
                    PayloadKeyView(lexiconItem: lexiconItem)
                }
            }
        }

        list
            .listRowBackground(Color.clear)
            .navigationTitle("Lexicon")
            .onAppear {
                lexiconService.getPayloadKeys(for: appID)
                lexiconService.getSignalTypes(for: appID)
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
