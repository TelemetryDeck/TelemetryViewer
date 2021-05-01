//
//  UserSettingsView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 07.09.20.
//

import SwiftUI
import TelemetryClient
import TelemetryModels

struct UserSettingsView: View {
    @EnvironmentObject var api: APIRepresentative
    @State private var showChangePasswordForm: Bool = false
    @State private var passwordChangeRequest = PasswordChangeRequestBody(oldPassword: "", newPassword: "", newPasswordConfirm: "")
    @State private var showingAlert = false
    
    var body: some View {
        if let user = api.user {
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("First Name").font(.footnote)
                        Text(user.firstName).bold()
                        Divider()
                        
                        Text("Last Name").font(.footnote)
                        Text(user.lastName).bold()
                        Divider()
                        
                        Text("Email").font(.footnote)
                        Text(user.email).bold()
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading) {
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
            }
            .padding()
            .navigationTitle("User Settings")
            .onAppear {
                TelemetryManager.shared.send(TelemetrySignal.userSettingsShown.rawValue, for: api.user?.email)
            }
        } else {
            Text("You are not logged in")
        }
    }
}
