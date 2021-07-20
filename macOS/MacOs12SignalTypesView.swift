//
//  MacOs12SignalTypesView.swift
//  Telemetry Viewer (macOS)
//
//  Created by Daniel Jilg on 20.07.21.
//

import SwiftUI

@available(macOS 12, *)
struct MacOs12SignalTypesView: View {
    @EnvironmentObject var lexiconService: LexiconService
    @State private var selection: DTO.LexiconSignalDTO.ID?
    @State private var sorting = [
        KeyPathComparator(\DTO.LexiconSignalDTO.type),
        KeyPathComparator(\DTO.LexiconSignalDTO.signalCount),
        KeyPathComparator(\DTO.LexiconSignalDTO.userCount)
    ]

    let appID: UUID

    var body: some View {
        Table(lexiconService.signalTypes(for: appID), selection: $selection, sortOrder: $sorting) {
            TableColumn("Type", value: \.type)
            TableColumn("Signals") { x in Text("\(x.signalCount)") }
            TableColumn("Users") { x in Text("\(x.userCount)") }
//                TableColumn("Sessions") { x in Text("\(x.sessionCount)")}
        }
        .navigationTitle("Lexicon")
        .onAppear {
            lexiconService.getSignalTypes(for: appID)
        }
    }
}
