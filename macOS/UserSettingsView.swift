//
//  UserSettingsView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 07.09.20.
//

import DataTransferObjects
import SwiftUI
import TelemetryClient

struct UserSettingsView: View {
    @EnvironmentObject var api: APIClient

    @State private var showingAlert = false
    @State private var userDTO = DTOv1.UserDTO(
        id: UUID(), organization: nil, firstName: "", lastName: "", email: "", emailIsVerified: false,
        receiveMarketingEmails: nil, isFoundingUser: false, receiveReports: .never
    )

    var body: some View {
        if api.user != nil {
            ScrollView {
                Form {
                    Text("User Settings")
                        .font(.title)
                        .padding(.bottom, 4)

                    CustomSection(
                        header: Text("Online Settings"),
                        summary: EmptyView(),
                        footer: Text("Change your user or organization settings online."),
                        startCollapsed: false
                    ) {
                        HStack {
                            Button {
                                URL(string: "https://dashboard.telemetrydeck.com/user/organization")!.open()
                            } label: {
                                Label("Organization Settings", systemImage: "app.badge")
                            }

                            if api.user != nil {
                                Button {
                                    URL(string: "https://dashboard.telemetrydeck.com/user/profile")!.open()
                                } label: {
                                    Label("User Settings", systemImage: "gear")
                                }
                            }
                        }
                    }

                    #if DEBUG
                    if let bearerTokenString = api.userToken?.bearerTokenAuthString {
                        CustomSection(header: Text("Token"), summary: Text(bearerTokenString), footer: EmptyView(), startCollapsed: false) {
                            Button(bearerTokenString) {
                                saveToClipBoard(bearerTokenString)
                            }
                        }
                    }
                    #endif

                    CustomSection(
                        header: Text("Log Out"),
                        summary: EmptyView(),
                        footer: EmptyView(),
                        startCollapsed: false
                    ) {
                        Button("Log Out \(api.user?.firstName ?? "User")") {
                            showingAlert = true
                        }
                        .alert(isPresented: $showingAlert) {
                            Alert(
                                title: Text("Really Log Out?"),
                                message: Text("You can log back in again later"),
                                primaryButton: .destructive(Text("Log Out")) {
                                    api.logout()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                }
                .padding()
                .onAppear {
                    if let user = api.user {
                        userDTO = user
                    }
                    TelemetryManager.shared.send(TelemetrySignal.userSettingsShown.rawValue, for: api.user?.email)
                }
            }
        } else {
            Text("You are not logged in")
        }
    }
}

struct SettingsKeyView: View {
    let key: String
    let value: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(key).font(.footnote)
            Text(value).bold()
        }
    }
}
