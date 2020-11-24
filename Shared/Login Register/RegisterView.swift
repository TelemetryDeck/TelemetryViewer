//
//  RegisterView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.08.20.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var api: APIRepresentative
    @State private var isLoading = false
    @State private var registrationRequestBody = RegistrationRequestBody()
    @State private var showingSuccessAlert = false
    @State private var error: TransferError?
    
    var body: some View {
        
        let errorBinding = Binding<Bool>(
            get: {
                error != nil
            },
            set: { value in
                
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
                            Section(header: Text("Registration Token"), footer: Text("Registration is currently only available for people with a registration token. Please enter your registration token above.")) {
                                TextField("Registration Token", text: $registrationRequestBody.registrationToken)
                                    .disableAutocorrection(true)
                            }
                            
                            #if os(macOS)
                            Divider()
                            #endif
                        }
                        
                        Section(header: Text("Your Organization")) {
                            TextField("Organization Name", text: $registrationRequestBody.organisationName)
                                .disableAutocorrection(true)
                        }
                        
                        Section(header: Text("You")) {
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
                        }
                        
                        Section(header: Text("Your Password")) {
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
                                .disabled(!registrationRequestBody.isValid || isLoading)
                                .saturation(registrationRequestBody.isValid ? 1 : 0)
                                .animation(.easeOut)
                            
                            if !registrationRequestBody.isValid {
                                Text(registrationRequestBody.userPassword.contains(":") ? "Your password cannot contain a colon (:) character because we use it to represent cute lil' piglets." : "Please fill out all the fields.")
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
            
            case .success(_):
                showingSuccessAlert = true
            case .failure(let error):
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
