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

            #if os(macOS)
                Image("sidebarBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(0.2)
                    .frame(maxWidth: 200)
                    .toolbar {
                        ToolbarItem {
                            #if os(macOS)
                                Button(action: toggleRightSidebar) {
                                    Image(systemName: "sidebar.right")
                                        .help("Toggle Sidebar")
                                }
                                .help("Toggle the right sidebar")
                            #else
                                EmptyView()
                            #endif
                        }
                    }
            #endif
        }
        .sheet(isPresented: $api.userNotLoggedIn, onDismiss: { api.userNotLoggedIn = api.userToken == nil }) {
            WelcomeView().accentColor(.telemetryOrange)
        }
        .alert(isPresented: $api.userLoginFailed, content: {
            Alert(
                title: Text("Login Failed"),
                message: Text("AppTelemetry could not connect to the server. Please check your internet connection."),
                primaryButton: .default(Text("Reload")) {
                    api.getUserInformation()
                },
                secondaryButton: .destructive(Text("Log Out")) {
                    api.logout()
                }
            )
        })
        .onAppear {
            #if os(macOS)
                setupSidebars()
            #endif
        }
    }
}
