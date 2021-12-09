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
        appService.create(appNamed: appName) { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(newApp):

                if self.createDefaultInsights {
                    let url = self.api.urlForPath(apiVersion: .v2, "apps", newApp.id.uuidString, "createDefaultInsights")

                    self.api.post("", to: url, defaultValue: nil) { (_: Result<String, TransferError>) in
                        self.appService.retrieveApp(with: newApp.id)
                        DispatchQueue.main.async {
                            self.newAppViewShown = false
                        }
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

    var body: some View {
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
                Button("Cancel") { createNewAppViewModel.newAppViewShown.toggle() }
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
}
