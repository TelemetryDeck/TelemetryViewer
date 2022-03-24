//
//  RootView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.09.20.
//

import DataTransferObjects
import SwiftUI
import WidgetKit

struct RootView: View {
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var orgService: OrgService
    @EnvironmentObject var appService: AppService

    var body: some View {
        if api.userNotLoggedIn {
            #if os(iOS)
            WelcomeView()

            #else
            HStack {
                Spacer()
                WelcomeView()
                    .frame(maxWidth: 600)
                    .alert(isPresented: $api.userLoginFailed, content: loginFailedView)
                Spacer()
            }
            #endif
        } else {
            NavigationView {
                LeftSidebarView()
                NoAppSelectedView()
            }
            .alert(isPresented: $api.userLoginFailed, content: loginFailedView)
            .onAppear {
                WidgetCenter.shared.reloadAllTimelines()
            }
            .task {
                if let organization = try? await orgService.retrieveOrganisation() {
                    var apps = [DTOv2.App.ID: DTOv2.App]()

                    for appID in organization.appIDs {
                        if let app = try? await appService.retrieveApp(withID: appID) {
                            apps[app.id] = app
                        }
                    }
                    
                    let appsDict = apps
                    let loadedOrganization = organization

                    DispatchQueue.main.async {
                        appService.appDictionary = appsDict
                        orgService.organization = loadedOrganization
                    }
                }
            }
        }
    }

    func loginFailedView() -> Alert {
        Alert(
            title: Text("Login Failed"),
            message: Text("TelemetryDeck could not connect to the server. Please check your internet connection. \(api.userLoginErrorMessage != nil ? api.userLoginErrorMessage! : "")"),
            primaryButton: .default(Text("Reload")) {
                api.getUserInformation()
            },
            secondaryButton: .destructive(Text("Log Out")) {
                api.logout()
            }
        )
    }
}
