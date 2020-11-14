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
    @State private var shouldShowJoinOrgScreen: Bool = false
    
    private var shouldShowLoginScreen: Bool {
        return api.userNotLoggedIn && !shouldShowJoinOrgScreen
    }
     
    @State private var organizationJoinRequest: OrganizationJoinRequestURLObject?
    
    var body: some View {
        NavigationView {
            SidebarView(selectedApp: $selectedApp)
                .sheet(isPresented: $shouldShowJoinOrgScreen) {
                    #if os(macOS)
                    if organizationJoinRequest != nil {
                        JoinOrganizationView(organizationJoinRequest: organizationJoinRequest!)
                            .environmentObject(api)
                    }
                    #else
                    NavigationView {
                        if organizationJoinRequest != nil {
                            JoinOrganizationView(organizationJoinRequest: organizationJoinRequest!)
                                .environmentObject(api)
                        }
                    }
                    #endif
                }
            Text("Please Select an App")
                
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .sheet(isPresented: .constant(shouldShowLoginScreen), onDismiss: { api.userNotLoggedIn = api.userToken == nil }) {
            WelcomeView()
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
                
                shouldShowJoinOrgScreen = true
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
