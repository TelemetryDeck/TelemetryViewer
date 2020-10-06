//
//  RegisterView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.08.20.
//

import SwiftUI

struct RegistrationRequestBody: Codable {
    var organisationName: String = ""
    var userFirstName: String = ""
    var userLastName: String = ""
    var userEmail: String = ""
    var userPassword: String = ""
    var userPasswordConfirm: String = ""
}

struct LoginRequestBody {
    var userEmail: String = ""
    var userPassword: String = ""
    
    var basicHTMLAuthString: String? {
        let loginString = "\(userEmail):\(userPassword)"
        guard let loginData = loginString.data(using: String.Encoding.utf8) else { return nil }
        let base64LoginString = loginData.base64EncodedString()
        return "Basic \(base64LoginString)"
    }
}

struct UserToken: Codable {
    var id: UUID?
    var value: String
    var user: [String: String]
    
    var bearerTokenAuthString: String {
        return "Bearer \(value)"
    }
}

struct RegisterView: View {
    @EnvironmentObject var api: APIRepresentative
    @State private var isLoading = false
    @State private var registrationRequestBody = RegistrationRequestBody()
    @State private var loginRequestBody = LoginRequestBody()
    
    var body: some View {
        Form {
            Section(header: Text("Your Organization")) {
                TextField("Organization Name", text: $registrationRequestBody.organisationName)
                    .disableAutocorrection(true)
            }
            
            Section(header: Text("You")) {
                TextField("First Name", text: $registrationRequestBody.userFirstName)
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
                } else {
                    Button("Register", action: register)
                }
            }
            
        }
        .disabled(isLoading)
        .navigationTitle("Register a new Organization")
    }
    
    func register() {
        isLoading = true
        api.register(registrationRequestBody: registrationRequestBody) {
            isLoading = false
        }
        
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
