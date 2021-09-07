//
//  RootView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.09.20.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var api: APIClient

    var body: some View {
        NavigationView {
            LeftSidebarView()
            AppInfoView()
        }
        .sheet(isPresented: $api.userNotLoggedIn, onDismiss: { api.userNotLoggedIn = api.userToken == nil }) {
            WelcomeView().accentColor(.telemetryOrange)
        }
        .alert(isPresented: $api.userLoginFailed, content: {
            Alert(
                title: Text("Login Failed"),
                message: Text("TelemetryDeck could not connect to the server. Please check your internet connection."),
                primaryButton: .default(Text("Reload")) {
                    api.getUserInformation()
                },
                secondaryButton: .destructive(Text("Log Out")) {
                    api.logout()
                }
            )
        })
    }
}
