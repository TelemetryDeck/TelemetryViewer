//
//  LoginView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.09.20.
//

import SwiftUI
import TelemetryModels

struct LoginView: View {
    @EnvironmentObject var api: APIRepresentative
    @State private var loginRequestBody = LoginRequestBody()
    @State private var isLoading = false
    @State private var showLoginErrorMessage = false

    var body: some View {
        Form {
            HStack {
                Spacer()
                Image("authentication").resizable().scaledToFit().frame(maxHeight: 200)
                Spacer()
            }

            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.telemetryOrange.opacity(0.1))

            if showLoginErrorMessage {
                VStack(alignment: .leading) {
                    Text("Login Failed").font(.title2)
                    Text("Something was wrong with your username or password. Please try again.")
                }
                .padding()
                .background(Color.red.opacity(0.2))
                .padding(.vertical)
                .animation(Animation.easeOut.speed(1.5))
                .transition(.move(edge: .top))
            }

            Section(header: Text("Login")) {
                #if os(macOS)
                    TextField("Email", text: $loginRequestBody.userEmail)
                        .textContentType(.username)
                #else
                    TextField("Email", text: $loginRequestBody.userEmail)
                        .textContentType(.username)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                #endif

                SecureField("Password", text: $loginRequestBody.userPassword)
                    .textContentType(.password)
            }

            Section {
                if isLoading {
                    ProgressView()
                } else {
                    Button("Login") {
                        isLoading = true
                        api.login(loginRequestBody: loginRequestBody) { success in
                            isLoading = false

                            showLoginErrorMessage = !success
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .listRowInsets(EdgeInsets())
                    .keyboardShortcut(.defaultAction)
                    .disabled(!loginRequestBody.isValid)
                    .saturation(loginRequestBody.isValid ? 1 : 0)
                    .animation(.easeOut)

                    if !loginRequestBody.isValid {
                        Text("Please fill out all the fields")
                            .font(.footnote)
                            .foregroundColor(.grayColor)
                    }
                }
            }
        }
        .navigationTitle("Login")
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
