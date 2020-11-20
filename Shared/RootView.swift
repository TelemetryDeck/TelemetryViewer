//
//  RootView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.09.20.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var api: APIRepresentative
    @State private var selectedApp: TelemetryApp?
     
    @State private var organizationJoinRequest: OrganizationJoinRequestURLObject?
    
    var body: some View {
        NavigationView {
            SidebarView(selectedApp: $selectedApp)
            Text(api.apps.count > 0 ? "Please Select an App" : "Welcome to Telemetry! Please create an app by tapping the plus button in the top left.")
                
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .sheet(isPresented: $api.userNotLoggedIn, onDismiss: { api.userNotLoggedIn = api.userToken == nil }) {
            WelcomeView().accentColor(Color("Torange"))
        }
        .onOpenURL { url in
            // telemetryviewer://registerUserToOrg/orgName/orgId/token/
            
            switch url.urlAction {
            case .registerUserToOrg:
                guard url.pathComponents.count >= 4 else { return }
                let orgName = url.pathComponents[1]
                let orgID = url.pathComponents[2]
                let token = url.pathComponents[3]
                
                guard let organization = UUID(uuidString: orgID) else { return }
                let request = OrganizationJoinRequestURLObject(
                    email: "",
                    firstName: "",
                    lastName: "",
                    password: "",
                    organizationID: organization,
                    organizationName: orgName,
                    registrationToken: token)
                organizationJoinRequest = request
                
//                shouldShowJoinOrgScreen = true
            default:
                print("Got a URL but don't know what to do with it, ignoring...")
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
