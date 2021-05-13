//
//  LexiconItemView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.10.20.
//

import SwiftUI

struct SignalTypeView: View {
    let lexiconItem: DTO.LexiconSignalDTO

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        ListItemView(background: Color.accentColor.opacity(0.2)) {
            Text(lexiconItem.type.camelCaseToWords)
                .bold()

            Spacer()

            ValueAndUnitView(value: Double(lexiconItem.signalCount), unit: "Signals", shouldFormatBigNumbers: true)
            ValueAndUnitView(value: Double(lexiconItem.userCount), unit: "Users", shouldFormatBigNumbers: true)
        }
    }
}

struct PayloadKeyView: View {
    let lexiconItem: DTO.LexiconPayloadKey

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        ListItemView {
            Text(lexiconItem.payloadKey.camelCaseToWords)
                .bold()

            Spacer()

            VStack(alignment: .trailing) {
                Text("First seen")
                Text("\(dateFormatter.string(from: lexiconItem.firstSeenAt))")
            }
            .foregroundColor(.grayColor)
            .font(.footnote)
        }
    }
}
