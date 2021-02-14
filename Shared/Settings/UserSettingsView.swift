//
//  UserSettingsView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 07.09.20.
//

import SwiftUI
import TelemetryClient

struct UserSettingsView: View {
    @EnvironmentObject var api: APIRepresentative
    @State private var showChangePasswordForm: Bool = false
    @State private var passwordChangeRequest = PasswordChangeRequestBody(oldPassword: "", newPassword: "", newPasswordConfirm: "")

    var body: some View {
        if let user = api.user {
            VStack(alignment: .leading) {
                HStack {
                    Text("First Name")
                    Text(user.firstName).bold()
                }

                HStack {
                    Text("Last Name")
                    Text(user.lastName).bold()
                }

                HStack {
                    Text("Email")
                    Text(user.email).bold()
                }

                Divider()

                Button("Log Out") {
                    api.logout()
                }

                Divider()

                if showChangePasswordForm {
                    Form {
                        SecureField("Old Password", text: $passwordChangeRequest.oldPassword)
                        SecureField("New Password", text: $passwordChangeRequest.newPassword)
                        SecureField("Confirm New Password", text: $passwordChangeRequest.newPasswordConfirm)

                        Button("Save New Password") {
                            api.updatePassword(with: passwordChangeRequest)
                        }
                    }
                    .frame(maxWidth: 400)
                } else {
                    Button("Change Password") {
                        showChangePasswordForm.toggle()
                    }
                }
            }
            .animation(.easeIn)
            .padding()
            .navigationTitle("User Settings")
            .onAppear {
                TelemetryManager.shared.send(TelemetrySignal.userSettingsShown.rawValue, for: api.user?.email)
            }
        }
    }
}
