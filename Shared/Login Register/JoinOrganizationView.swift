//
//  JoinOrganizationView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 11.11.20.
//

import SwiftUI

struct JoinOrganizationView: View {
    @EnvironmentObject var api: APIClient
    @Environment(\.presentationMode) var presentationMode

    @State var error: TransferError?
    @State var isLoading: Bool = false
    @State var organizationJoinRequestToken: String = ""
    @State var organizationJoinRequestPresent: Bool = false
    @State var organizationJoinRequest = DTOv1.OrganizationJoinRequestDTO(
        email: "", receiveMarketingEmails: false, firstName: "", lastName: "", password: "",
        organizationID: UUID(), registrationToken: ""
    )

    var orgJoinRequestIsValid: Bool {
        !organizationJoinRequest.email.isEmpty &&
            !organizationJoinRequest.firstName.isEmpty &&
            !organizationJoinRequest.password.isEmpty
    }

    var orgJoinRequestErrorHint: String {
        "Please fill all the fields"
    }

    var body: some View {
        if isLoading {
            Spacer()
            ProgressView()
            Spacer()
        } else if organizationJoinRequestPresent {
            Group {
                CustomSection(header: Text("Email"), summary: EmptyView(), footer: EmptyView()) {
                    TextField("Email", text: $organizationJoinRequest.email)
                    Text("In addition to emails like password reset requests and security alerts, we might inform you every now and then about news and best practices regarding TelemetryDeck. Can we also send you our low volume newsletter please?")
                        .font(.footnote)
                        .foregroundColor(.grayColor)
                    
                    Toggle("Send me the newsletter", isOn: $organizationJoinRequest.receiveMarketingEmails)
                }

                CustomSection(header: Text("Name"), summary: EmptyView(), footer: Text("What should we call you?")) {
                    TextField("First Name", text: $organizationJoinRequest.firstName)
                    TextField("Last Name", text: $organizationJoinRequest.lastName)
                }

                CustomSection(header: Text("Password"), summary: EmptyView(), footer: Text("Please define a secure password")) {
                    SecureField("Password", text: $organizationJoinRequest.password)
                }

                if isLoading {
                    ProgressView()
                } else {
                    Button("Create Account") {
                        isLoading = true

                        api.joinOrganization(with: organizationJoinRequest) { result in
                            isLoading = false

                            switch result {
                            case .success:
                                api.login(
                                    loginRequestBody: LoginRequestBody(
                                        userEmail: organizationJoinRequest.email,
                                        userPassword: organizationJoinRequest.password
                                    )
                                ) { _ in
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            case let .failure(error):
                                print(error.localizedDescription)
                            }
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(!orgJoinRequestIsValid)
                    .saturation(orgJoinRequestIsValid ? 1 : 0)
                    .buttonStyle(PrimaryButtonStyle())

                    if !orgJoinRequestIsValid {
                        Text(orgJoinRequestErrorHint)
                            .font(.footnote)
                            .foregroundColor(.grayColor)
                    }
                }
            }
        } else {
            Group {
                Text("Hi! You're invited to an organization on Telemetry. This means you can see and edit all apps and insights that belong to the organization.")

                Spacer()

                if let error = error {
                    Text(error.localizedDescription)
                        .bold()
                }

                Section(header: Text("Please enter your registration Token")) {
                    TextField("Registration Token", text: $organizationJoinRequestToken)
                }

                Spacer()
                Button("Continue") {
                    isLoading = true

                    api.getOrganizationJoinRequest(with: organizationJoinRequestToken) { result in
                        switch result {
                        case let .success(joinRequest):
                            organizationJoinRequest = DTOv1.OrganizationJoinRequestDTO(
                                email: joinRequest.email,
                                receiveMarketingEmails: false,
                                firstName: "",
                                lastName: "",
                                password: "",
                                organizationID: joinRequest.organization["id"]!,
                                registrationToken: joinRequest.registrationToken
                            )
                            organizationJoinRequestPresent = true
                        case let .failure(error):
                            self.error = error
                        }

                        isLoading = false
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(organizationJoinRequestToken.isEmpty)
                .saturation(organizationJoinRequestToken.isEmpty ? 0 : 1)
                .buttonStyle(PrimaryButtonStyle())
                .animation(.easeOut)

                if organizationJoinRequestToken.isEmpty {
                    Text("Please enter a valid registration token")
                        .font(.footnote)
                        .foregroundColor(.grayColor)
                        .animation(.easeOut)
                }
            }
            .animation(.easeOut)
        }
    }
}

struct JoinOrganizationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            JoinOrganizationView()
        }
        .previewLayout(.fixed(width: 600, height: 800))
        .environmentObject(APIClient())
    }
}
