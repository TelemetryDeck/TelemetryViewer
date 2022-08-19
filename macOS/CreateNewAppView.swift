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
        ZStack {
            Circle().fill(Color.grayColor.opacity(0.3))
            Image("sidebarBackground")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 200)
        }
        .padding()
    }

    var formContent: some View {
        VStack {
            sondrine

            VStack(alignment: .leading) {
                TextField("New App Name", text: $createNewAppViewModel.appName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Text(createNewAppViewModel.isValid.string ?? "")
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minHeight: 30)
                    .font(.footnote)
                    .foregroundColor(.grayColor)
            }

            Toggle(isOn: $createNewAppViewModel.createDefaultInsights) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Add Default Insights")
                        Text("We'll automatically create a number of Groups and Insights for you, that will fit most apps. " +
                            "You can change or delete these later, but they're usually a good starting point.")
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.footnote)
                            .foregroundColor(.grayColor)
                    }
                    Spacer()
                }
            }
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

    func appCreatedView(newApp: DTOv2.App) -> some View {
        VStack(spacing: 20) {
            Text("You have created a new App! Awesome!")
                .font(.title)
                .foregroundColor(.grayColor)

            Text("We've created your new app")

            if createNewAppViewModel.createDefaultInsights {
                Text("We also created a number of default Insights and Groups for you.")
            } else {
                Text("You'll be able to create new Groups and Insights by navigating to the new app and using the buttons in the toolbar.")
            }
            Text("The next step is implementing the TelemetryDeck SDK. Hit the Documentation button to read more.")

            Button("Open Documentation") {
                URL(string: "https://telemetrydeck.com/pages/quickstart.html")?.open()
            }
            .buttonStyle(SmallSecondaryButtonStyle())

            Spacer()

            Text("Click to copy this UUID into your apps for tracking. You can look up this ID later by going to the app settings.")

            Button(newApp.id.uuidString) {
                saveToClipBoard(newApp.id.uuidString)
            }
            .buttonStyle(SmallPrimaryButtonStyle())
        }
        .toolbar {
            ToolbarItemGroup(placement: .confirmationAction) {
                Button("Dismiss") { createNewAppViewModel.newAppViewShown = false }
                    .keyboardShortcut(.defaultAction)
            }
        }
    }

    var body: some View {
        HStack {
            if let newApp = createNewAppViewModel.createdApp {
                appCreatedView(newApp: newApp)
            } else {
                formContent
            }
        }
        .frame(minWidth: 400, maxWidth: 600)
        .padding()
    }
}
