//
//  MacOs12SignalTypesView.swift
//  Telemetry Viewer (macOS)
//
//  Created by Daniel Jilg on 20.07.21.
//

import SwiftUI

@available(macOS 12, *)
struct MacOs12RecentSignalsView: View {
    @EnvironmentObject var signalsService: SignalsService
    @State var searchText: String = ""

    let appID: UUID

    var table: some View {
        Table(signalsService.signals(for: appID)) {
            TableColumn("Received") { signal in
                Text(signal.receivedAt.formatted(date: .abbreviated, time: .shortened))
            }
            TableColumn("Type", value: \.type)
            TableColumn("Count") { signal in Text("\(signal.count)") }
                .width(50)

            TableColumn("User") { signal in
                Text(String(signal.clientUser.prefix(8)))
            }
            TableColumn("Session") { signal in
                Text(String(signal.sessionID.prefix(8)))
            }
        }
    }

    var explanationView: some View {
        ScrollView {
            SignalListExplanationView().padding()
        }
    }

    var body: some View {
        ZStack {
            table
                .navigationTitle("Recent Signals")
                .onAppear {
                    signalsService.getSignals(for: appID)
                }
                .toolbar {
                    if signalsService.isLoading(appID: appID) {
                        ProgressView().scaleEffect(progressViewScaleLarge, anchor: .center)
                    } else {
                        Button(action: {
                            signalsService.getSignals(for: appID)
                        }, label: {
                            Image(systemName: "arrow.counterclockwise.circle")
                        })
                    }
                }

            NavigationLink("", destination: explanationView, isActive: .constant(true)).hidden()
        }
    }
}
