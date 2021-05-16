//
//  RegisterView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.08.20.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var api: APIRepresentative
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoading = false
    @State private var registrationRequestBody = DTO.RegistrationRequestBody()
    @State private var showingSuccessAlert = false
    @State private var error: TransferError?

    var body: some View {
        let errorBinding = Binding<Bool>(
            get: {
                error != nil
            },
            set: { _ in
            }
        )

        if showingSuccessAlert {
            VStack {
                Text("Woohoo!").font(.largeTitle)
                Text("You've registered successfully! Please log in now.")
            }
        } else {
            Form {
                if let registrationStatus = api.registrationStatus {
                    if registrationStatus == .closed {
                        Text("Registration is currently closed. Please try again later.")
                            .foregroundColor(.grayColor)
                    } else {
                        if registrationStatus == .tokenOnly {
                            CustomSection(header: Text("Registration Token"), summary: EmptyView(), footer: Text("Registration is currently only available for people with a registration token. Please enter your registration token above.")) {
                                TextField("Registration Token", text: $registrationRequestBody.registrationToken)
                                    .disableAutocorrection(true)
                            }

                            #if os(macOS)
                                Divider()
                            #endif
                        }

                        CustomSection(header: Text("Your Organization"), summary: EmptyView(), footer: EmptyView()) {
                            TextField("Organization Name", text: $registrationRequestBody.organisationName)
                                .disableAutocorrection(true)
                        }

                        CustomSection(header: Text("You"), summary: EmptyView(), footer: EmptyView()) {
                            TextField("First Name (or Display Name)", text: $registrationRequestBody.userFirstName)
                            TextField("Last Name", text: $registrationRequestBody.userLastName)

                            #if os(macOS)
                                TextField("Email", text: $registrationRequestBody.userEmail)
                            #else
                                TextField("Email", text: $registrationRequestBody.userEmail)
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            #endif
                            
                            Text("In addition to emails like password reset requests and security alerts, we might inform you every now and then about news and best practices regarding AppTelemetry. Can we also send you our low volume newsletter please?")
                                .font(.footnote)
                                .foregroundColor(.grayColor)
                            
                            Toggle("Send me the newsletter", isOn: $registrationRequestBody.receiveMarketingEmails)
                        }

                        CustomSection(header: Text("Your Password"), summary: EmptyView(), footer: EmptyView()) {
                            SecureField("Password", text: $registrationRequestBody.userPassword)
                            SecureField("Confirm Password", text: $registrationRequestBody.userPasswordConfirm)
                        }

                        Section {
                            if isLoading {
                                ProgressView()
                            }
                            Button("Register", action: register)
                                .buttonStyle(PrimaryButtonStyle())
                                .listRowInsets(EdgeInsets())
                                .keyboardShortcut(.defaultAction)
                                .disabled(registrationRequestBody.isValid != .valid || isLoading)
                                .saturation(registrationRequestBody.isValid == .valid ? 1 : 0)
                                .animation(.easeOut)

                            if registrationRequestBody.isValid != .valid {
                                Group {
                                    switch registrationRequestBody.isValid {
                                    case .valid:
                                        EmptyView()
                                    case .fieldsMissing:
                                        Text("Please fill out all the fields.")
                                    case .passwordsNotEqual:
                                        Text("Your passwords don't match. Please check that they're the same.")
                                    case .passwordTooShort:
                                        Text("Your passwords needs at least 8 characters.")
                                    case .passwordContainsColon:
                                        Text("Your password cannot contain a colon (:) character because we use it to represent cute lil' piglets.")
                                    case .noAtInEmail:
                                        Text("Email parsing is hard, but shouldn't there be an @ sign in your email address?")
                                    }
                                }
                                .font(.footnote)
                                .foregroundColor(.grayColor)
                            }
                        }
                        .alert(isPresented: errorBinding) {
                            Alert(title: Text("Something went wrong"), message: Text(error?.localizedDescription ?? "No Error Message"), dismissButton: .default(Text("Oof!")))
                        }
                    }

                } else {
                    ProgressView()
                }
            }
            .disabled(isLoading)
            .navigationTitle("Register")
            .alert(isPresented: $showingSuccessAlert) {
                Alert(title: Text("Registration Success"), message: Text("You're now officially registered with Telemetry. Please log in now!"), dismissButton: .default(Text("Got it!")))
            }
            .onAppear {
                api.getRegistrationStatus()
            }
            .animation(.easeInOut)
            .frame(idealHeight: 500)
        }
    }

    func register() {
        isLoading = true
        api.register(registrationRequestBody: registrationRequestBody) { result in
            isLoading = false

            switch result {
            case .success:
                showingSuccessAlert = true
                
                api.login(
                    loginRequestBody: LoginRequestBody(
                        userEmail: registrationRequestBody.userEmail,
                        userPassword: registrationRequestBody.userPassword
                    )
                ) { _ in
                    self.presentationMode.wrappedValue.dismiss()
                }
            case let .failure(error):
                self.error = error
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
