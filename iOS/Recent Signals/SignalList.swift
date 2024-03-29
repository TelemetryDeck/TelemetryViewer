//
//  SignalList.swift
//  Telemetry Viewer (iOS)
//
//  Created by Martin Václavík on 26.12.2021.
//

import DataTransferObjects
import SwiftUI
import TelemetryClient

struct SignalList: View {
    @EnvironmentObject var signalsService: SignalsService
    @EnvironmentObject var queryService: QueryService

    @State var filterText: String = ""

    let appID: UUID

    var body: some View {
        TestModeIndicator()
        List {
            Section {
                TextField("Search", text: $filterText)
                SignalListExplanationView()
            }

            Section {
                if signalsService.signals(for: appID).isEmpty && !signalsService.isLoading(appID: appID) {
                    Text("You haven't received any Signals yet. Once your app is sending out signals, " +
                         "you'll find here a list of the latest ones.\n\nHint: Usually, apps using the " +
                         "Telemetry Swift Client will only send out Signals if they are compiled in the " +
                         "Release build configuration. If your schema is in Debug mode, no signals will be sent.")
                        .font(.footnote)
                        .foregroundColor(.grayColor)
                }
                let signals = signalsService.signals(for: appID)
                    .filter {
                        $0.isTestMode == queryService.isTestingMode &&
                        (filterText.isEmpty ||
                         $0.type.lowercased().contains(filterText.lowercased()) ||
                         $0.clientUser.lowercased().contains(filterText.lowercased()))
                    }
                ForEach(signals) { signal in
                    NavigationLink(
                        destination: SignalView(signal: signal.signal),
                        label: { SignalListCell(signal: signal.signal) }
                    )
                }
            }
            .id(UUID())
        }
        .refreshable {
            await signalsService.getSignalsAsync(for: appID)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Recent Signals")
        .onAppear {
            signalsService.getSignals(for: appID)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if signalsService.isLoading(appID: appID) {
                    ProgressView().scaleEffect(progressViewScaleLarge, anchor: .center)
                }
            }
            ToolbarItem(placement: .automatic) {
                Toggle("Test Mode", isOn: $queryService.isTestingMode.animation())
            }
        }
    }
}
