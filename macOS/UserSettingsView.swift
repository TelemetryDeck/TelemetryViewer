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
    @State private var userDTO = DTO.UserDTO(id: UUID(), organization: nil, firstName: "", lastName: "", email: "", emailIsVerified: false, receiveMarketingEmails: nil, isFoundingUser: false)
    @State var isShowingSaveButtons: Bool = false
    
    func boolToString(value: Bool?) -> String {
        if let value = value {
            return value ? "Yes" : "No"
        } else {
            return "Not decided yet"
        }
    }
    
    func showSaveButtons() {
        withAnimation {
            isShowingSaveButtons = true
        }
    }
    
    func save() {
        api.updateUser(with: userDTO)
    }
    
    var body: some View {
        if api.user != nil {
            ScrollView {
                Form {
                    Text("User Settings")
                        .font(.title)
                        .padding(.bottom, 4)
                    
                    CustomSection(
                        header: Text("Name"),
                        summary: Text("\(userDTO.firstName) \(userDTO.lastName)"),
                        footer: Text("Your first and last name. If you only have one name, please use the First Name field."),
                        startCollapsed: true
                    ) {
                        HStack {
                            TextField("First Name", text: $userDTO.firstName)
                                .onChange(of: userDTO.firstName) { _ in showSaveButtons() }
                            TextField("Last Name", text: $userDTO.lastName)
                                .onChange(of: userDTO.lastName) { _ in showSaveButtons() }
                            
                            if isShowingSaveButtons {
                                Button("Save") { save() }
                            }
                        }
                    }
                    
                    CustomSection(
                        header: Text("Email"),
                        summary: Text(userDTO.email),
                        footer: Text("In addition to emails like password reset requests and security alerts, we might inform you every now and then about news and best practices regarding AppTelemetry. Can we also send you our low volume newsletter please?"),
                        startCollapsed: true
                    ) {
                        HStack {
                            TextField("Email", text: $userDTO.email)
                                .onChange(of: userDTO.email) { _ in showSaveButtons() }
                            if isShowingSaveButtons {
                                Button("Save") { save() }
                            }
                        }
                        
                        OptionalToggle(description: "Receive the newsletter?", isOn: $userDTO.receiveMarketingEmails)
                            .onChange(of: userDTO.receiveMarketingEmails) { _ in save() }
                    }
                    
                    CustomSection(
                        header: Text("Change Password"),
                        summary: EmptyView(),
                        footer: EmptyView(),
                        startCollapsed: true
                    ) {
                        SecureField("Old Password", text: $passwordChangeRequest.oldPassword)
                        SecureField("New Password", text: $passwordChangeRequest.newPassword)
                        SecureField("Confirm New Password", text: $passwordChangeRequest.newPasswordConfirm)
                        
                        Button("Save New Password") {
                            api.updatePassword(with: passwordChangeRequest) { _ in
                                withAnimation {
                                    showChangePasswordForm = false
                                }
                            }
                        }
                    }
                    
                    CustomSection(
                        header: Text("Log Out"),
                        summary: EmptyView(),
                        footer: EmptyView(),
                        startCollapsed: true
                    ) {
                        Button("Click Here To Log Out") {
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
