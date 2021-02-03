//
//  CreateOrganizationJoinRequestView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 11.11.20.
//

import SwiftUI

struct CreateOrganizationJoinRequestView: View {
    @EnvironmentObject var api: APIRepresentative
    @Environment(\.presentationMode) var presentationMode

    @State var inviteeEmail: String = ""

    private var isValidEmail: Bool {
        if inviteeEmail.count < 3 { return false }
        if !inviteeEmail.contains("@") { return false}
        if !inviteeEmail.contains(".") { return false }

        return true
    }

    var body: some View {

        VStack(alignment: .leading) {

            Text("Invite People to join \(api.user?.organization?.name ?? "your organization")")
                .font(.title)

            Text("Please enter your collaborator's email address here. We'll send them an email with an invitation code and instructions on how to download the app.")

            Spacer()

            #if os(iOS)
            TextField("Email", text: $inviteeEmail)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            #else
            TextField("Email", text: $inviteeEmail)
                .padding()
            #endif

            Spacer()

            Button("Send Email") {
                api.createOrganizationJoinRequest(for: inviteeEmail) {_ in 
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
            .keyboardShortcut(.defaultAction)
            .disabled(!isValidEmail)
            .saturation(isValidEmail ? 1 : 0)
            .animation(.easeOut)
            .buttonStyle(PrimaryButtonStyle())

            if !isValidEmail {
                Text("Please enter a valid email address")
                    .font(.footnote)
                    .foregroundColor(.grayColor)
                    .animation(.easeOut)
            }

            Button("Cancel") {
                self.presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(SmallSecondaryButtonStyle())
        }
        .padding()
        .frame(maxWidth: 400, minHeight: 400)
    }
}

struct CreateOrganizationJoinRequestView_Previews: PreviewProvider {
    static var previews: some View {
        CreateOrganizationJoinRequestView()
            .environmentObject(APIRepresentative())
    }
}
