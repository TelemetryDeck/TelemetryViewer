//
//  MacOs12SignalTypesView.swift
//  Telemetry Viewer (macOS)
//
//  Created by Daniel Jilg on 20.07.21.
//

import SwiftUI
import DataTransferObjects

@available(macOS 12, *)
struct MacOs12SignalTypesView: View {
    @EnvironmentObject var lexiconService: LexiconService
    @State private var sortOrder: [KeyPathComparator<DTOv1.LexiconSignalDTO>] = [
        .init(\.type, order: SortOrder.forward)
    ]
    @State var searchText: String = ""

    let appID: UUID

    var table: some View {
        // Every now and then, this table will fail to compile with
        // "The compiler is unable to type-check this expression in reasonable time".
        // The solution is to sigh, say "thanks SwiftUI" and comment out one of the table columns.
        // Once the app has compiled, comment it back in.
        Table(signalTypes, sortOrder: $sortOrder) {
            TableColumn("Type", value: \.type)
            TableColumn("Signals", value: \.signalCount) { x in Text("\(x.signalCount)") }
            TableColumn("Users", value: \.userCount) { x in Text("\(x.userCount)") }
            // TableColumn("Sessions", value: \.sessionCount) { x in Text("\(x.sessionCount)") }
        }
        .navigationTitle("Signal Types")
        .onAppear {
            lexiconService.getSignalTypes(for: appID)
        }
    }

    var explanationView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("This list contains all Signal Types seen by TelemetryDeck in the last month.")
        }
        .padding()
        .font(.footnote)
        .foregroundColor(.grayColor)
    }

    var body: some View {
        SidebarSplitView {
            table
            explanationView
        } toolbar: {
            ToolbarItemGroup {
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
        }
    }

    var signalTypes: [DTOv1.LexiconSignalDTO] {
        return lexiconService.signalTypes(for: appID)
            .filter {
                searchText.isEmpty ? true : $0.type.localizedCaseInsensitiveContains(searchText)
            }
            .sorted(using: sortOrder)
    }
}
