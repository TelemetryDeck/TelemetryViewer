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
    @State private var showingAlert = false
    
    func boolToString(value: Bool?) -> String {
        if let value = value {
            return value ? "Yes" : "No"
        } else {
            return "Not decided yet"
        }
    }
    
    var body: some View {
        if let user = api.user {
            VStack(alignment: .leading, spacing: 8) {
                Text("User Settings").font(.title)
                
                Group {
                    SettingsKeyView(key: "First Name", value: user.firstName)
                    SettingsKeyView(key: "Last Name", value: user.lastName)
                    SettingsKeyView(key: "Email", value: user.email)
                    SettingsKeyView(key: "Receive the Newsletter?", value: boolToString(value: user.receiveMarketingEmails))
                    SettingsKeyView(key: "Email is verified?", value: boolToString(value: user.emailIsVerified))
                }
                
                Divider()
                
                Button("Log Out") {
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
                
                if !showChangePasswordForm {
                    Button("Change Password") {
                        withAnimation {
                            showChangePasswordForm.toggle()
                        }
                    }
                }
                
                if showChangePasswordForm {
                    Divider()
                
                    Form {
                        SecureField("Old Password", text: $passwordChangeRequest.oldPassword)
                        SecureField("New Password", text: $passwordChangeRequest.newPassword)
                        SecureField("Confirm New Password", text: $passwordChangeRequest.newPasswordConfirm)
                
                        HStack {
                            Button("Cancel") {
                                withAnimation {
                                    showChangePasswordForm = false
                                }
                            }
                
                            Spacer()
                
                            Button("Save New Password") {
                                api.updatePassword(with: passwordChangeRequest) { _ in
                                    withAnimation {
                                        showChangePasswordForm = false
                                    }
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .onAppear {
                TelemetryManager.shared.send(TelemetrySignal.userSettingsShown.rawValue, for: api.user?.email)
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
