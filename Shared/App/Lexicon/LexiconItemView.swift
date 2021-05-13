//
//  LexiconItemView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.10.20.
//

import SwiftUI

struct SignalTypeView: View {
    let lexiconItem: DTO.LexiconSignalDTO

    var body: some View {
        HStack {
            Text(lexiconItem.type)
                .bold()

            Spacer()

            Text("–").animatableNumber(value: Double(lexiconItem.signalCount), unit: "Signals", shouldFormatBigNumbers: true)
                .foregroundColor(.grayColor)
            
            Text("–").animatableNumber(value: Double(lexiconItem.userCount), unit: "Users", shouldFormatBigNumbers: true)
                .foregroundColor(.grayColor)
            
            Text("–").animatableNumber(value: Double(lexiconItem.sessionCount), unit: "Sessions", shouldFormatBigNumbers: true)
                .foregroundColor(.grayColor)
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
        HStack {
            Text(lexiconItem.payloadKey)
                .bold()

            Spacer()

            Text("First seen ")
                .foregroundColor(.grayColor)
            +
            
            Text(lexiconItem.firstSeenAt, style: .date)
                .foregroundColor(.grayColor)
        }
    }
}
