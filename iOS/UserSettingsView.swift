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
            
            Form {
                Section {
                    VStack(alignment: .leading) {
                        Text("First Name").font(.footnote)
                        Text(user.firstName).bold()
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Last Name").font(.footnote)
                        Text(user.lastName).bold()
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Email").font(.footnote)
                        Text(user.email).bold()
                    }
                    
                    Button("Log Out") {
                        api.logout()
                    }
                }
                

                if showChangePasswordForm {
                        SecureField("Old Password", text: $passwordChangeRequest.oldPassword)
                        SecureField("New Password", text: $passwordChangeRequest.newPassword)
                        SecureField("Confirm New Password", text: $passwordChangeRequest.newPasswordConfirm)

                        Button("Cancel") {
                            withAnimation {
                                showChangePasswordForm = false
                            }
                        }
                        
                        Button("Save New Password") {
                            api.updatePassword(with: passwordChangeRequest) { _ in
                                    withAnimation {
                                        showChangePasswordForm = false
                                    }
                            }
                        }
                } else {
                    Button("Change Password") {
                        withAnimation {
                            showChangePasswordForm.toggle()
                        }
                    }
                }
            }
            .navigationTitle("User Settings")
            .onAppear {
                TelemetryManager.shared.send(TelemetrySignal.userSettingsShown.rawValue, for: api.user?.email)
            }
        } else {
            Text("You are not logged in")
        }
    }
}
