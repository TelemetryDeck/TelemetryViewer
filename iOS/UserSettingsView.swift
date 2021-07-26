//
//  UserSettingsView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 07.09.20.
//

import SwiftUI
import TelemetryClient

struct UserSettingsView: View {
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var appService: AppService
    @State private var showChangePasswordForm: Bool = false
    @State private var showingAlert = false
    @State private var passwordChangeRequest = PasswordChangeRequestBody(oldPassword: "", newPassword: "", newPasswordConfirm: "")
    @State var userDTO: DTO.UserDTO
    
    func save() {
        api.updateUser(with: userDTO)
    }

    var body: some View {
        if api.user != nil {
            Form {
                Section(header: Text("Name"), footer: Text("Your first and last name. If you only have one name, please use the First Name field.")) {
                    TextField("First Name", text: $userDTO.firstName)
                    TextField("Last Name", text: $userDTO.lastName)
                }
                
                Section(header: Text("Email"), footer: Text("In addition to emails like password reset requests and security alerts, we might inform you every now and then about news and best practices regarding AppTelemetry. Can we also send you our low volume newsletter please?")) {
                    TextField("Email", text: $userDTO.email)
                    
                    OptionalToggle(description: "Receive the newsletter?", isOn: $userDTO.receiveMarketingEmails)
                        .onChange(of: userDTO.receiveMarketingEmails) { _ in save() }
                }
                
                Section {
                    Button("Log Out") {
                        showingAlert = true
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(
                            title: Text("Really Log Out?"),
                            message: Text("You can log back in again later"),
                            primaryButton: .destructive(Text("Log Out")) {
                                api.logout()
                                appService.logout()
                            },
                            secondaryButton: .cancel()
                        )
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
                if let user = api.user {
                    userDTO = user
                }
                TelemetryManager.shared.send(TelemetrySignal.userSettingsShown.rawValue, for: api.user?.email)
            }
            .toolbar {
                Button("Save") {
                    save()
                }
            }
        } else {
            Text("You are not logged in")
        }
    }
}
