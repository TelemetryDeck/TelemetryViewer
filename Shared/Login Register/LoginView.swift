//
//  LoginView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.09.20.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var api: APIRepresentative
    @State private var loginRequestBody = LoginRequestBody()
    @State private var isLoading = false
    
    var body: some View {
        Form {
            Section(header: Text("Login")) {
                
                #if os(macOS)
                    TextField("Email", text: $loginRequestBody.userEmail)
                #else
                    TextField("Email", text: $loginRequestBody.userEmail)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                #endif
                
                SecureField("Password", text: $loginRequestBody.userPassword)
            }
            
            Section {
                if isLoading {
                    ProgressView()
                } else {
                    Button("Login") {
                        isLoading = true
                        api.login(loginRequestBody: loginRequestBody) {
                            isLoading = false
                        }
                    }
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
