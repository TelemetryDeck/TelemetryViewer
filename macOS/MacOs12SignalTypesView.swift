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
    @State private var sortOrder: [KeyPathComparator<DTO.LexiconSignalDTO>] = [
        .init(\.type, order: SortOrder.forward)
    ]
    @State var searchText: String = ""

    let appID: UUID

    var table: some View {
        Table(signalTypes, sortOrder: $sortOrder) {
            TableColumn("Type", value: \.type)
            TableColumn("Signals", value: \.signalCount) { x in Text("\(x.signalCount)") }
            TableColumn("Users", value: \.userCount) { x in Text("\(x.userCount)") }
            TableColumn("Sessions", value: \.sessionCount) { x in Text("\(x.sessionCount)") }
        }
    }

    var explanationView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("This list contains all Signal Types seen by AppTelemetry in the last month.")
            }
            .padding()
            .font(.footnote)
            .foregroundColor(.grayColor)
        }
    }

    var body: some View {
        ZStack {
            table
//                .searchable(text: $searchText)
                .navigationTitle("Signal Types")
                .onAppear {
                    lexiconService.getSignalTypes(for: appID)
                }
                .toolbar {
                    if lexiconService.isLoading(appID: appID) {
                        ProgressView().scaleEffect(progressViewScaleLarge, anchor: .center)
                    } else {
                        Button(action: {
                            lexiconService.getSignalTypes(for: appID)
                        }, label: {
                            Image(systemName: "arrow.counterclockwise.circle")
                        })
                    }
                }

            NavigationLink("", destination: explanationView, isActive: .constant(true)).hidden()
        }
    }

    var signalTypes: [DTO.LexiconSignalDTO] {
        return lexiconService.signalTypes(for: appID)
            .filter {
                searchText.isEmpty ? true : $0.type.localizedCaseInsensitiveContains(searchText)
            }
            .sorted(using: sortOrder)
    }
}
