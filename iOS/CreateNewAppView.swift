//
//  CreateNewAppView.swift
//  Telemetry Viewer
//
//  Created by Charlotte Böhm on 01.12.21.
//

import DataTransferObjects
import SwiftUI

struct CreateNewAppView: View {
    @StateObject var createNewAppViewModel: CreateNewAppViewModel

    var sondrine: some View {
        Image("sidebarBackground")
            .resizable()
            .scaledToFit()
            .listRowBackground(Color.clear)
    }

    var createDefaultAppsSection: some View {
        Section {
            Toggle(isOn: $createNewAppViewModel.createDefaultInsights) {
                Text("Add Default Insights")
            }
        } footer: {
            Text("We'll automatically create a number of Groups and Insights for you, that will fit most apps. You can change or delete these later, but they're usually a good starting point.")
        }
    }

    var nameSection: some View {
        Section {
            TextField("New App Name", text: $createNewAppViewModel.appName)
        } footer: {
            Text(createNewAppViewModel.isValid.string ?? "")
                .foregroundColor(.grayColor)
        }
        .navigationTitle("Create a new App")
        .toolbar {
            ToolbarItemGroup(placement: .cancellationAction) {
                Button("Cancel") { createNewAppViewModel.newAppViewShown = false }
                    .keyboardShortcut(.cancelAction)
            }

            ToolbarItemGroup(placement: .confirmationAction) {
                Button("Create App") { createNewAppViewModel.createNewApp() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(createNewAppViewModel.isValid == .nameEmpty)
                    .help("Create App")
            }
        }
    }

    func copyAppIDSection(newApp: DTOv2.App) -> some View {
        Section {
            Button(newApp.id.uuidString) {
                saveToClipBoard(newApp.id.uuidString)
            }
        } footer: {
            Text("Tap to copy this UUID into your apps for tracking. You can look up this ID later by going to the app settings.")
        }
    }

    func documentationSection(newApp: DTOv2.App) -> some View {
        Section {
            Button("Open Documentation") {
                URL(string: "https://telemetrydeck.com/pages/quickstart.html")?.open()
            }
        } footer: {
            Text("We've created your new app.\(createNewAppViewModel.createDefaultInsights ? " We also created a number of default Insights and Groups for you." : "You'll be able to create new Groups and Insights by navigating to the new app and using the buttons in the toolbar.")\n\nThe next step is implementing the TelemetryDeck SDK. Hit the Documentation button to read more.")
        }
        .navigationTitle("App Created")
        .toolbar {
            ToolbarItemGroup(placement: .confirmationAction) {
                Button("Dismiss") { createNewAppViewModel.newAppViewShown = false }
                    .keyboardShortcut(.defaultAction)
            }
        }
    }

    var body: some View {
        Form {
            if let newApp = createNewAppViewModel.createdApp {
                documentationSection(newApp: newApp)
                copyAppIDSection(newApp: newApp)
            } else {
                sondrine
                nameSection
                createDefaultAppsSection
            }
        }
    }
}
