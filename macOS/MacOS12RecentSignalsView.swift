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
    @State private var sortOrder: [KeyPathComparator<DTO.IdentifiableSignal>] = [
        .init(\.receivedAt, order: SortOrder.reverse)
    ]
    @State var searchText: String = ""

    let appID: UUID

    var table: some View {
        Table(signalTypes, sortOrder: $sortOrder) {
            TableColumn("Received", value: \.receivedAt) { signal in
                Text(signal.receivedAt.formatted(date: .abbreviated, time: .shortened))
            }
            TableColumn("Type", value: \.type)
            TableColumn("Count", value: \.count) { signal in Text("\(signal.count)") }
                .width(50)

            TableColumn("User", value: \.clientUser) { signal in
                Text(String(signal.clientUser.prefix(8)))
            }
            TableColumn("Session", value: \.sessionID) { signal in
                Text(String(signal.sessionID.prefix(8)))
            }
        }
    }

    var body: some View {
        table
            .searchable(text: $searchText)
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
    }

    var signalTypes: [DTO.IdentifiableSignal] {
        return signalsService.signals(for: appID)
            .filter {
                searchText.isEmpty ? true : ($0.type.localizedCaseInsensitiveContains(searchText) ||
                                             $0.clientUser.localizedCaseInsensitiveContains(searchText))
            }
            .sorted(using: sortOrder)
    }
}
