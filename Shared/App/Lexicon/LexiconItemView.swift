//
//  LexiconItemView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.10.20.
//

import SwiftUI

struct SignalTypeView: View {
    let lexiconItem: DTO.LexiconSignalDTO
    let compressed: Bool

    var body: some View {
        HStack {
            Text(lexiconItem.type)
                .bold()

            Spacer()

            Text("–").animatableNumber(value: Double(lexiconItem.signalCount), shouldFormatBigNumbers: true)
                .foregroundColor(.grayColor)
                .modify {
                    if compressed {
                        $0.frame(minWidth: 10, alignment: .trailing)
                    } else {
                        $0.frame(minWidth: 40, alignment: .trailing)
                    }
                }
                .padding(.horizontal)

            Text("–").animatableNumber(value: Double(lexiconItem.userCount), shouldFormatBigNumbers: true)
                .foregroundColor(.grayColor)
                .modify {
                    if compressed {
                        $0.frame(minWidth: 10, alignment: .trailing)
                    } else {
                        $0.frame(minWidth: 40, alignment: .trailing)
                    }
                }
                .padding(.horizontal)

            Text("–").animatableNumber(value: Double(lexiconItem.sessionCount), shouldFormatBigNumbers: true)
                .foregroundColor(.grayColor)
                .modify {
                    if compressed {
                        $0.frame(minWidth: 10, alignment: .trailing)
                    } else {
                        $0.frame(minWidth: 40, alignment: .trailing)
                    }
                }
                .padding(.horizontal)
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
