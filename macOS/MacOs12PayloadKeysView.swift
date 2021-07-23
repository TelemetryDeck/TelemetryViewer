//
//  MacOs12SignalTypesView.swift
//  Telemetry Viewer (macOS)
//
//  Created by Daniel Jilg on 20.07.21.
//

import SwiftUI

@available(macOS 12, *)
struct MacOs12PayloadKeysView: View {
    @EnvironmentObject var lexiconService: LexiconService
    @State private var sortOrder: [KeyPathComparator<DTO.LexiconPayloadKey>] = [
        .init(\.payloadKey, order: SortOrder.forward)
    ]
    @State var searchText: String = ""

    let appID: UUID

    var table: some View {
        Table(payloadTypes, sortOrder: $sortOrder) {
            TableColumn("Key", value: \.payloadKey)
            TableColumn("First Seen", value: \.firstSeenAt) { x in Text("\(x.firstSeenAt, style: .date)") }
        }
    }

    var explanationView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("This list contains all available payload keys known to AppTelemetry.")
            }
            .padding()
            .font(.footnote)
            .foregroundColor(.grayColor)
        }
    }

    var body: some View {
        ZStack {
            table
                .searchable(text: $searchText)
                .navigationTitle("Payload Keys")
                .onAppear {
                    lexiconService.getPayloadKeys(for: appID)
                }
                .toolbar {
                    if lexiconService.isLoading(appID: appID) {
                        ProgressView().scaleEffect(progressViewScaleLarge, anchor: .center)
                    } else {
                        Button(action: {
                            lexiconService.getPayloadKeys(for: appID)
                        }, label: {
                            Image(systemName: "arrow.counterclockwise.circle")
                        })
                    }
                }
            
            NavigationLink("", destination: explanationView, isActive: .constant(true)).hidden()
        }
    }

    var payloadTypes: [DTO.LexiconPayloadKey] {
        return lexiconService.payloadKeys(for: appID)
            .filter {
                searchText.isEmpty ? true : $0.payloadKey.localizedCaseInsensitiveContains(searchText)
            }
            .sorted(using: sortOrder)
    }
}
