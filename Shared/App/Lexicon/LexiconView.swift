//
//  LexiconView.swift
//  Telemetry Viewer (iOS)
//
//  Created by Daniel Jilg on 28.10.20.
//

import SwiftUI
import TelemetryClient

struct LexiconView: View {
    @EnvironmentObject var lexiconService: LexiconService

    @State private var sortKey: LexiconService.LexiconSortKey = .signalCount

    #if os(iOS)
        @Environment(\.horizontalSizeClass) var sizeClass
    #endif

    private var shouldCompressTitles: Bool {
        #if os(iOS)
            return sizeClass == .compact
        #else
            return false
        #endif
    }

    let appID: UUID

    var body: some View {
        if #available(macOS 12, *) {
            Table(lexiconService.signalTypes(for: appID, sortedBy: sortKey)) {
                TableColumn("Type", value: \.type)
//                TableColumn("age", value: \.signalCount) { Text("\($0.signalCount)") }
//                TableColumn("id", value: \.id) { Text("\($0.id)") }
//                TableColumn("Users", value: \.userCount) { bla in Text("\(bla)") }
//                TableColumn("Users", value: \.userCount)
//                TableColumn("Sessions", value: \.sessionCount)
            }
            .navigationTitle("Lexicon")
            .onAppear {
                lexiconService.getPayloadKeys(for: appID)
                lexiconService.getSignalTypes(for: appID)
            }
        } else {
            let list = List {
                Section(header: HStack {
                    Button {
                        withAnimation {
                            sortKey = .type
                        }
                    } label: {
                        Label("Signal Types", systemImage: sortKey == .type ? "arrowtriangle.down.circle.fill" : "circle")
                    }

                    Spacer()

                    Button {
                        withAnimation {
                            sortKey = .signalCount
                        }
                    } label: {
                        if shouldCompressTitles {
                            Image(systemName: sortKey == .signalCount ? "number.circle.fill" : "number.circle")
                                .padding()
                        } else {
                            Label("Signals", systemImage: sortKey == .signalCount ? "arrowtriangle.down.circle.fill" : "circle")
                        }
                    }

                    Button {
                        withAnimation {
                            sortKey = .userCount
                        }
                    } label: {
                        if shouldCompressTitles {
                            Image(systemName: sortKey == .userCount ? "person.circle.fill" : "person.circle")
                                .padding()
                        } else {
                            Label("Users", systemImage: sortKey == .userCount ? "arrowtriangle.down.circle.fill" : "circle")
                        }
                    }

                    Button {
                        withAnimation {
                            sortKey = .sessionCount
                        }
                    } label: {
                        if shouldCompressTitles {
                            Image(systemName: sortKey == .sessionCount ? "link.circle.fill" : "link.circle")
                                .padding()
                        } else {
                            Label("Sessions", systemImage: sortKey == .sessionCount ? "arrowtriangle.down.circle.fill" : "circle")
                        }
                    }
                }, footer:
                Text("This list contains all Signal Types seen by to AppTelemetry in the last month.")
                    .font(.footnote)
                    .foregroundColor(.grayColor)
                    .multilineTextAlignment(.center)) {
                        ForEach(lexiconService.signalTypes(for: appID, sortedBy: sortKey)) { lexiconItem in
                            SignalTypeView(lexiconItem: lexiconItem, compressed: shouldCompressTitles)
                        }
                }

                Section(header: Text("Payload Keys"), footer:
                    Text("This list contains all available payload keys known to AppTelemetry.")
                        .font(.footnote)
                        .foregroundColor(.grayColor)
                        .multilineTextAlignment(.center)) {
                        ForEach(lexiconService.payloadKeys(for: appID)) { lexiconItem in
                            PayloadKeyView(lexiconItem: lexiconItem)
                        }
                }
            }

            list
                .listRowBackground(Color.clear)
                .navigationTitle("Lexicon")
                .onAppear {
                    lexiconService.getPayloadKeys(for: appID)
                    lexiconService.getSignalTypes(for: appID)
                }
        }
    }
}

struct LexiconView_Previews: PreviewProvider {
    static var previews: some View {
        return NavigationView {
            LexiconView(appID: UUID())
                .environmentObject(MockLexiconService() as LexiconService)
        }
    }
}
