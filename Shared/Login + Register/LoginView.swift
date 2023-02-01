//
//  LoginView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.09.20.
//

import SwiftUI
import DataTransferObjects

struct LoginView: View {
    @EnvironmentObject var api: APIClient
    @State private var loginRequestBody = LoginRequestBody()
    @State private var isLoading = false
    @State private var showLoginErrorMessage = false

    var body: some View {
        Form {
            ZStack(alignment: .bottom) {
                HStack {
                    Spacer()

                    Image("authentication")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 300)

                    Spacer()
                }

                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.telemetryOrange.opacity(0.1))

                if showLoginErrorMessage {
                    VStack(alignment: .leading) {
                        Text("Login Failed").font(.title2)
                        Text("Something was wrong with your username or password. Please check your spelling and try again.")
                        Text("If you can't remember, use the password reset button on the welcome page.").font(.footnote)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.telemetryOrange)
                    .cornerRadius(15)
                    .padding(.vertical)
                    .animation(Animation.easeOut.speed(1.5), value: showLoginErrorMessage)
                    .transition(.move(edge: .top))
                }
            }

            Section {
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

                SecureField("Password", text: $loginRequestBody.userPassword, onCommit: login)
                    .textContentType(.password)
            }

            Section {
                if isLoading {
                    ProgressView()
                } else {
                    Button("Login", action: login)
                        .buttonStyle(PrimaryButtonStyle())
                        .listRowInsets(EdgeInsets())
                        .keyboardShortcut(.defaultAction)
                        .disabled(!loginRequestBody.isValid)
                        .saturation(loginRequestBody.isValid ? 1 : 0)
                        .animation(.easeOut, value: loginRequestBody.isValid)

                    if !loginRequestBody.isValid {
                        Text("Waiting for you to fill out both fields")
                            .font(.footnote)
                            .foregroundColor(.grayColor)
                    }
                }
            }
        }
        .navigationTitle("Login")
    }

    func login() {
        isLoading = true
        api.login(loginRequestBody: loginRequestBody) { success in
            isLoading = false

            showLoginErrorMessage = !success
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(APIClient())
    }
}
