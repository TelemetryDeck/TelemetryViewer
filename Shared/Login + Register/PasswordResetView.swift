//
//  PasswordResetView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 17.03.21.
//

import SwiftUI
import DataTransferObjects
import TelemetryDeckClient

struct PasswordResetView: View {
    enum ProgressStatus {
        case loading
        case request
        case confirm
        case error
        case success
    }

    @EnvironmentObject var api: APIClient
    @State var requestPasswordResetRequestBody = RequestPasswordResetRequestBody()
    @State var progressStatus: ProgressStatus = .request
    @State var message: String = ""

    var body: some View {
        Form {
            if !message.isEmpty {
                Text(message)
                Divider()
            }

            switch progressStatus {
            case .loading:
                ProgressView()

            case .request:
                CustomSection(header: Text("Email Address"), summary: EmptyView(), footer: Text("Please enter the email address you used to register with TelemetryDeck. You'll receive an email with a reset code.")) {
                    #if os(macOS)
                        TextField("Email", text: $requestPasswordResetRequestBody.email)
                    #else
                        TextField("Email", text: $requestPasswordResetRequestBody.email)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    #endif

                    Button("Request Code") {
                        progressStatus = .loading
                        api.requestPasswordReset(with: requestPasswordResetRequestBody.email) { result in
                            switch result {
                            case let .success(message):
                                self.message = message["message"] ?? message["error"] ?? ""
                                self.progressStatus = .confirm
                            case let .failure(error):
                                self.message = error.localizedDescription
                                self.progressStatus = .error
                            }
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!requestPasswordResetRequestBody.isValidEmailAddress)
                    .saturation(requestPasswordResetRequestBody.isValidEmailAddress ? 1 : 0)
                }

            case .confirm:
                CustomSection(header: Text("Reset Code"), summary: EmptyView(), footer: Text("Check your email and paste the reset code you received into this field please.")) {
                    TextField("Reset Code", text: $requestPasswordResetRequestBody.code)
                }

                CustomSection(header: Text("New Password"), summary: EmptyView(), footer: Text("Please enter your new password here.")) {
                    SecureField("New Password", text: $requestPasswordResetRequestBody.newPassword)
                }

                Button("Reset Password") {
                    api.confirmPasswordReset(with: requestPasswordResetRequestBody) { result in
                        switch result {
                        case let .success(message):
                            self.message = message["message"] ?? message["error"] ?? ""
                            self.progressStatus = .success
                        case let .failure(error):
                            self.message = error.localizedDescription
                            self.progressStatus = .error
                        }
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!requestPasswordResetRequestBody.isValid)
                .saturation(requestPasswordResetRequestBody.isValid ? 1 : 0)

            case .error:
                Image(systemName: "exclamationmark.triangle.fill")

            case .success:
                Image(systemName: "checkmark.shield")
            }
        }
        .navigationTitle("Password Reset")
    }
}

struct PasswordResetView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordResetView()
    }
}
