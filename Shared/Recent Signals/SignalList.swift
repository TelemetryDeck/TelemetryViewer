//
//  SignalList.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 11.08.20.
//

import DataTransferObjects
import SwiftUI
import TelemetryClient

struct SignalList: View {
    @EnvironmentObject var signalsService: SignalsService

    @State var filterText: String = ""
    @State var selectedSignal: DTOv1.IdentifiableSignal?

    let appID: UUID

    var body: some View {
        HStack(spacing: 0) {
            List(selection: $selectedSignal) {
                TextField("Search", text: $filterText)

                SignalListExplanationView()

                if signalsService.signals(for: appID).isEmpty && !signalsService.isLoading(appID: appID) {
                    Text("You haven't received any Signals yet. Once your app is sending out signals, you'll find here a list of the latest ones.\n\nHint: Usually, apps using the Telemetry Swift Client will only send out Signals if they are compiled in the Release build configuration. If your schema is in Debug mode, no signals will be sent.")
                        .font(.footnote)
                        .foregroundColor(.grayColor)
                }

                let signals = signalsService.signals(for: appID)
                    .filter {
                        filterText.isEmpty ||
                            $0.type.lowercased().contains(filterText.lowercased()) ||
                            $0.clientUser.lowercased().contains(filterText.lowercased())
                    }

                ForEach(signals, id: \.id) { signal in
                    #if os(macOS)
                    SignalListCell(signal: signal.signal).tag(signal)
                    #else
                    NavigationLink(
                        destination: SignalView(signal: signal.signal),
                        label: { SignalListCell(signal: signal.signal) }
                    )
                    #endif
                }
            }

            #if os(macOS)
            Divider()
            if let selectedSignal = selectedSignal {
                SignalView(signal: selectedSignal.signal)
            } else {
                Text("Select a Signal")
                    .foregroundColor(.grayColor)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            #endif
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
    let signal: DTOv1.Signal

    var body: some View {
        AdaptiveStack(horizontalAlignment: .leading) {
            HStack {
                Text(signal.receivedAt, style: .date)
                Text(signal.receivedAt, style: .time)
            }
            .font(.footnote)
            .foregroundColor(.secondary)

            Text(signal.type).bold()

            if signal.isTestMode {
                Text("Test Signal")
                    .foregroundColor(Color.secondary)
                    .font(.footnote)
            }
        }
    }
}

struct SignalListExplanationView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("These are the latest signals TelemetryDeck has received from your app.")
            Text("Timestamps have a granularity of one hour, and multiple identical signals might get grouped into one entry using the 'count' property.")
        }
        .font(.footnote)
        .foregroundColor(.grayColor)
    }
}
