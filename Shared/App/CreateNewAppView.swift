//
//  CreateNewAppView.swift
//  Telemetry Viewer
//
//  Created by Charlotte Böhm on 01.12.21.
//

import DataTransferObjects
import SwiftUI

class CreateNewAppViewModel: ObservableObject {
    let api: APIClient
    let orgService: OrgService
    let appService: AppService

    @Published var appName: String = "New App"
    @Published var existingApps: [DTOv2.App] = []
    @Published var createDefaultInsights: Bool = true
    @Published var appCreated: Bool = false
    @Published var createdApp: DTOv2.App? = nil

    @Binding var newAppViewShown: Bool

    public init(api: APIClient, appService: AppService, orgService: OrgService, newAppViewShown: Binding<Bool>) {
        self.api = api
        self.orgService = orgService
        self.appService = appService
        _newAppViewShown = newAppViewShown
        existingApps = appsFromAppIDs()
    }

    public var isValid: AppCreationValidationState {
        if appName.isEmpty {
            return .nameEmpty
        }

        if (existingApps.filter {
            $0.name.lowercased() == appName.lowercased()
        } != []) {
            return .nameAlreadyUsed
        }

        if appName == "New App" {
            return .nameNewApp
        }

        return .valid
    }

    func appsFromAppIDs() -> [DTOv2.App] {
        var apps: [DTOv2.App] = []
        guard orgService.organization != nil else { return [] }
        for appID in orgService.organization!.appIDs {
            guard appService.app(withID: appID) != nil else { continue }
            apps.append(appService.app(withID: appID)!)
        }
        return apps
    }

    func createNewApp() {
        let url = api.urlForPath(apiVersion: .v2, "apps")

        api.post(["name": appName], to: url) { [unowned self] (result: Result<DTOv2.App, TransferError>) in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(newApp):
                if self.createDefaultInsights {
                    let url = self.api.urlForPath(apiVersion: .v2, "apps", newApp.id.uuidString, "createDefaultInsights")

                    self.api.post("", to: url, defaultValue: nil) { (_: Result<Data, TransferError>) in
                        DispatchQueue.main.async {
                            self.createdApp = newApp
                            self.appCreated = true
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.createdApp = newApp
                        self.appCreated = true
                    }
                }
            }
        }
    }
}

enum AppCreationValidationState {
    case valid
    case nameEmpty
    case nameAlreadyUsed
    case nameNewApp

    var string: String? {
        switch self {
        case .valid:
            return nil
        case .nameEmpty:
            return "Please fill out the app name field."
        case .nameAlreadyUsed:
            return "You already have an app with that name. Are you sure you want to create another app with the same name? (You can change the app name later.)"
        case .nameNewApp:
            return "You did not change the app name yet. Do you really want to name your app 'New App'? (You can change the app name later.)"
        }
    }
}

struct CreateNewAppView: View {
    @StateObject var createNewAppViewModel: CreateNewAppViewModel

    var formContent: some View {
        VStack {
            Image("sidebarBackground")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 200)

            #if os(iOS)
            Spacer()
            #endif

            Form {
                Section {
                    TextField("New App Name", text: $createNewAppViewModel.appName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Toggle(isOn: $createNewAppViewModel.createDefaultInsights) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Add Default Insights")
                                Text("We'll automatically create a number of Groups and Insights for you, that will fit most apps. You can change or delete these later, but they're usually a good starting point.")
                                    .font(.footnote)
                                    .foregroundColor(.grayColor)
                            }
                            Spacer()
                        }
                    }
                }

                Section {
                    Text(createNewAppViewModel.isValid.string ?? "")
                        .font(.footnote)
                        .foregroundColor(.grayColor)
                }
            }
            .padding()
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

    var appCreatedView: some View {
        Group {
            if let newApp = createNewAppViewModel.createdApp {
                VStack(spacing: 20) {
                    Spacer()
                    Text("You have created a new App! Awesome!")
                        .font(.title)
                        .foregroundColor(.grayColor)

                    if !createNewAppViewModel.createDefaultInsights {
                        Text("An app contains Insight Groups, which in turn contain Insights.")
                            .foregroundColor(.grayColor)

                        Image(systemName: "square.grid.2x2.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.grayColor)

                        #if os(macOS)
                        Text("Create your first Insight Group now by clicking the New Group button in the top left.")
                            .foregroundColor(.grayColor)
                        #else
                        Text("Create your first Insight Group now by tapping 'New Insight Group' in the toolbar.")
                            .foregroundColor(.grayColor)
                        #endif
                    }

                    Text("Create your first Insight Group now by clicking the New Group button in the top left.")
                        .foregroundColor(.grayColor)

                    Button("Documentation: Sending Signals") {
                        URL(string: "https://telemetrydeck.com/pages/quickstart.html")?.open()
                    }
                    .buttonStyle(SmallSecondaryButtonStyle())

                    Spacer()

                    CustomSection(header: Text("Unique Identifier"), summary: EmptyView(), footer: EmptyView()) {
                        VStack(alignment: .leading) {
                            Button(newApp.id.uuidString) {
                                saveToClipBoard(newApp.id.uuidString)
                            }
                            .buttonStyle(SmallPrimaryButtonStyle())
                            #if os(macOS)
                            Text("Click to copy this UUID into your apps for tracking.").font(.footnote)
                            #else
                            Text("Tap to copy this UUID into your apps for tracking.").font(.footnote)
                            #endif
                        }
                    }

                    .toolbar {
                        ToolbarItemGroup(placement: .confirmationAction) {
                            Button("Dismiss") { createNewAppViewModel.newAppViewShown = false }
                                .keyboardShortcut(.defaultAction)
                        }
                    }
                }
            } else {
                Text("Something went wrong.")
            }
        }
    }

    var body: some View {
        HStack {
            if createNewAppViewModel.appCreated {
                appCreatedView
                    .padding()
            } else {
                formContent
                    .padding()
            }
        }
    }
}
