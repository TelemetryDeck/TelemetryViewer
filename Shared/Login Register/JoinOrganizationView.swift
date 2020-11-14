//
//  JoinOrganizationView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 11.11.20.
//

import SwiftUI

struct JoinOrganizationView: View {
    @EnvironmentObject var api: APIRepresentative
    @Environment(\.presentationMode) var presentationMode
    
    @State var organizationJoinRequest: OrganizationJoinRequestURLObject
    @State var isLoading: Bool = false
    
    var body: some View {
        let form = Form {
            Text("Hi! You're invited to join the organization '\(organizationJoinRequest.organizationName)' on Telemetry. This means you can see and edit all apps and insights that belong to the organization. To continue, please create an account, which will then belong to the organization.")
            
            Section(header: Text("What's your email address?")) {
                TextField("Email", text: $organizationJoinRequest.email)
            }
            
            Section(header: Text("What should we call you?")) {
                TextField("First Name", text: $organizationJoinRequest.firstName)
                TextField("Last Name", text: $organizationJoinRequest.lastName)
            }
            
            Section(header: Text("Password"), footer: Text("Please define a secure password")) {
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
                        case .success(_):
                            api.login(
                                loginRequestBody: LoginRequestBody(
                                    userEmail: organizationJoinRequest.email,
                                    userPassword: organizationJoinRequest.password)
                            ) { _ in
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
        
        #if os(macOS)
        VStack(alignment: .leading) {
            Text("Join \(organizationJoinRequest.organizationName)")
                .font(.title)
                .padding(.bottom)
            form.frame(maxWidth: 600)
        }
        .padding()
        #else
        form.navigationTitle("Join \(organizationJoinRequest.organizationName)")
        #endif
    }
}

struct JoinOrganizationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            JoinOrganizationView(organizationJoinRequest: OrganizationJoinRequestURLObject(
                                    email: "winsmith@winsmith.de",
                                    firstName: "Dimitrij",
                                    lastName: "Popov",
                                    password: "",
                                    organizationID: UUID(),
                                    organizationName: "btsystem",
                                    registrationToken: "ABCDE"))
        }
        .previewLayout(.fixed(width: 600, height: 800))
        .environmentObject(APIRepresentative())
    }
}
