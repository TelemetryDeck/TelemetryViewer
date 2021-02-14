//
//  NewDerivedStatisticGroupView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 21.09.20.
//

import SwiftUI

struct NewInsightGroupView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var api: APIRepresentative
    var app: TelemetryApp

    @State var title: String = "New Insight Group"

    var body: some View {
        let saveButton = Button("Save") {
            api.create(insightGroupNamed: title, for: app)
            self.presentationMode.wrappedValue.dismiss()
        }
        .keyboardShortcut(.defaultAction)

        let cancelButton = Button("Cancel") {
            self.presentationMode.wrappedValue.dismiss()
        }
        .keyboardShortcut(.cancelAction)

        let form = Form {
            #if os(macOS)
                Text("New Insight Group")
                    .font(.title2)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
            #endif

            Section(header: Text("New Insight Group"), footer: Text("Insight Groups are a named collection of insights, to help you group and organize them. Please provide a title for the new group")) {
                TextField("Title", text: $title)
            }

            #if os(macOS)
                HStack {
                    cancelButton
                    Spacer()
                    saveButton
                }
            #endif
        }

        #if os(macOS)
            form
                .padding()
        #else
            NavigationView {
                form
                    .navigationTitle("New Insight Group")
                    .navigationBarItems(leading: cancelButton, trailing: saveButton)
            }
        #endif
    }
}
