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
    
    @State var organizationJoinRequest: OrganizationJoinRequest
    @State var isLoading: Bool = false
    
    var body: some View {
        HStack {
            Form {
                Text("Hi! You're invited to join the organization '\(organizationJoinRequest.organizationName)' on Telemetry. This means you can see and edit all apps and insights that belong to the organization. To continue, please create an account, which will then belong to the organization.")
                
                Section(header: Text("What's your email address?")) {
                    TextField("Email", text: $organizationJoinRequest.email)
                }
                
                Section(header: Text("Password"), footer: Text("Please define a secure password, and just to be sure, enter it twice.")) {
                    SecureField("Password", text: $organizationJoinRequest.password)
                    SecureField("Confirm Password", text: $organizationJoinRequest.password)
                }
                
                if isLoading {
                    ProgressView()
                } else {
                    Button("Create Account") {
                        isLoading = true
                        
                        api.joinOrganization(with: organizationJoinRequest) { success in
                            isLoading = false
                            
                            if success {
                                api.login(
                                    loginRequestBody: LoginRequestBody(
                                        userEmail: organizationJoinRequest.email,
                                        userPassword: organizationJoinRequest.password)
                                ) { _ in
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Join \(organizationJoinRequest.organizationName)")
        }
    }
}

struct JoinOrganizationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            JoinOrganizationView(organizationJoinRequest: OrganizationJoinRequest(
                                    organizationName: "Cool Org",
                                    organizationID: UUID(),
                                    email: "winsmith@winsmith.de",
                                    password: "",
                                    organizationJoinToken: "ABCDE"))
        }
        .previewLayout(.fixed(width: 600, height: 800))
        .environmentObject(APIRepresentative())
    }
}
