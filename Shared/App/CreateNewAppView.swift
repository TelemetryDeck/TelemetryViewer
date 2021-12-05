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
            Form {
                Section {
                    TextField("App Name", text: $createNewAppViewModel.appName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Toggle(isOn: $createNewAppViewModel.createDefaultInsights) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Create default Insights")
                                Text("Check to have some default Insights created for you.")
                                    .font(.footnote)
                                    .foregroundColor(.grayColor)
                            }
                            Spacer()
                        }
                    }
                }

                Section {
                    if createNewAppViewModel.isValid.string != nil {
                        Text(createNewAppViewModel.isValid.string!)
                            .font(.footnote)
                            .foregroundColor(.grayColor)
                    }
                }
            }

            Spacer()

            Image("sidebarBackground").resizable().scaledToFit()
        }
        .navigationTitle("Create a new App")
        .toolbar {
            ToolbarItemGroup {
                Button(action: createNewAppViewModel.createNewApp) {
                    Text("Create App")
                    Image(systemName: "plus.app")
                        .help("Create App")
                }
                .disabled(createNewAppViewModel.isValid == .nameEmpty)
                .help("Create App")
                .foregroundColor(createNewAppViewModel.isValid == .nameEmpty ? Color.secondary : Color.telemetryOrange)
            }
        }
    }
}
