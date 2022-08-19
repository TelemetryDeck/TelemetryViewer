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
    @EnvironmentObject var queryService: QueryService

    @State var filterText: String = ""
    @State var selectedSignal: DTOv1.IdentifiableSignal?

    let appID: UUID

    var body: some View {
        VStack {
            TestModeIndicator()
            HStack(spacing: 0) {
                List(selection: $selectedSignal) {
                    TextField("Search", text: $filterText)
                    SignalListExplanationView()

                    Section {
                        if signalsService.signals(for: appID).isEmpty && !signalsService.isLoading(appID: appID) {
                            Text("You haven't received any Signals yet. Once your app is sending out signals, you'll find " +
                                 "here a list of the latest ones.\n\nHint: Usually, apps using the Telemetry Swift Client " +
                                 "will only send out Signals if they are compiled in the Release build configuration. " +
                                 "If your schema is in Debug mode, no signals will be sent.")
                                .font(.footnote)
                                .foregroundColor(.grayColor)
                        }
                        let signals = signalsService.signals(for: appID)
                            .filter {
                                filterText.isEmpty ||
                                    $0.type.lowercased().contains(filterText.lowercased()) ||
                                    $0.clientUser.lowercased().contains(filterText.lowercased())
                            }
                            .filter {
                                $0.isTestMode == queryService.isTestingMode
                            }

                        ForEach(signals, id: \.id) { signal in
                            SignalListCell(signal: signal.signal).tag(signal)
                        }
                    }
                }
                Divider()
                if let selectedSignal = selectedSignal {
                    SignalView(signal: selectedSignal.signal)
                } else {
                    Text("Select a Signal")
                        .foregroundColor(.grayColor)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .navigationTitle("Recent Signals")
            .onAppear {
                signalsService.getSignals(for: appID)
            }
            .toolbar {
                TextField("Filter", text: $filterText)
                    .frame(minWidth: 120)

                TestingModeToggle()

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
}
