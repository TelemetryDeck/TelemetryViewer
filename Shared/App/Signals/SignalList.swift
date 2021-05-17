//
//  SignalList.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 11.08.20.
//

import SwiftUI
import TelemetryClient

struct SignalList: View {
    @EnvironmentObject var signalsService: SignalsService

    @State var filterText: String = ""

    let appID: UUID

    var body: some View {
        List {
            #if os(iOS)
            TextField("Search", text: $filterText)
                .padding(7)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            #endif
            
            Text("These are the latest signals AppTelemetry has received from your app. Signals receive time have a granularity of one hour, and identical signals get grouped into one entry. Tap a signal for more information.")
                .font(.footnote)
                .foregroundColor(.grayColor)

            if signalsService.signals(for: appID).isEmpty && !signalsService.isLoading(appID: appID) {
                Text("You haven't received any Signals yet. Once your app is sending out signals, you'll find here a list of the latest ones.\n\nHint: Usually, apps using the Telemetry Swift Client will only send out Signals if they are compiled in the Release build configuration. If your schema is in Debug mode, no signals will be sent.")
                    .font(.footnote)
                    .foregroundColor(.grayColor)
            }

            let signals = signalsService.signals(for: appID)
                .map { $0.toIdentifiableSignal() }
                .filter {
                    filterText.isEmpty ||
                        $0.type.lowercased().contains(filterText.lowercased()) ||
                        $0.clientUser.lowercased().contains(filterText.lowercased())
                }

            ForEach(signals) { signal in
                NavigationLink(
                    destination: SignalView(signal: signal.signal),
                    label: { SignalListCell(signal: signal.signal) }
                )
            }
        }
        .navigationTitle("Recent Signals")
        .onAppear {
            signalsService.getSignals(for: appID)
        }
        .toolbar {
            #if os(macOS)
            TextField("Filter", text: $filterText)
                .frame(minWidth: 120)
            #endif

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
    }
}

struct SignalListCell: View {
    let signal: DTO.Signal

    var body: some View {
        HStack {
            Text(signal.type).bold()
            Spacer()
            Text(signal.receivedAt, style: .date).opacity(0.6)
            Text(signal.receivedAt, style: .time).opacity(0.6)
        }
    }
}
