//
//  CreateOrganizationJoinRequestView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 11.11.20.
//

import SwiftUI

struct CreateOrganizationJoinRequestView: View {
    @EnvironmentObject var api: APIRepresentative
    @Binding var organizationJoinRequest: OrganizationJoinRequest?
    
    var invitationMessage: String {
        return """
        Hi!

        Someone from the \(api.user?.organization?.name ?? "Nonexistant") Organization has invited you to join their Telemetry Account.

        Telemetry is an analytics service with added privacy. Using Telemetry, you'll get accurate, real-time information about how users are using your apps.

        To join the organization, you'll need to install the Telemetry Viewer app first. Get it from the following link and then return to this message:

        iOS:
        https://testflight.apple.com/join/NsC8gxIt

        macOS 11:
        https://github.com/AppTelemetry/Viewer/releases

        Once you have Telemetry Viewer installed on your device, tap the following link to create an account and join the organization:

        telemetryviewer://registerUserToOrg/\(api.user?.organization?.name ?? "Nonexistant")/\(api.user?.organization?.id?.uuidString ?? "Nonexistant")/\(organizationJoinRequest!.registrationToken )/

        See you soon!
        Daniel from Telemetry
        """
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Here's an organization Join Request. Please copy and send it to the person you want to invite via email or message:")
                .foregroundColor(.grayColor)
            TextEditor(text: .constant(invitationMessage))
            
            Button("Delete this Join Request") {
                if let organizationJoinRequest = organizationJoinRequest {
                    api.delete(organizationJoinRequest: organizationJoinRequest)
                }
            }
        }
        .padding()
    }
}

//struct CreateOrganizationJoinRequestView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateOrganizationJoinRequestView()
//            .environmentObject(APIRepresentative())
//    }
//}
