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
     
    @State private var organizationJoinRequest: OrganizationJoinRequest?
    
    var body: some View {
        NavigationView {
            SidebarView(selectedApp: $selectedApp)
            Text("Please Select an App")
                .sheet(isPresented: $shouldShowJoinOrgScreen) {
                    #if os(macOS)
                    JoinOrganizationView()
                    #else
                    NavigationView {
                        organizationJoinRequest.map {
                            JoinOrganizationView(organizationJoinRequest: $0)
                                .environmentObject(api)
                        }
                    }
                    #endif
                }
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .sheet(isPresented: .constant(shouldShowLoginScreen), onDismiss: { api.userNotLoggedIn = api.userToken == nil }) {
            WelcomeView()
        }
        .onOpenURL { url in
            // telemetryviewer://registerUserToOrg/orgName/a9d847cd-fb46-427c-b044-4fbb9aa00414/useremail/token/
            
            switch url.urlAction {
            case .registerUserToOrg:
                guard url.pathComponents.count >= 5 else { return }
                let orgName = url.pathComponents[1]
                let orgID = url.pathComponents[2]
                let userEmail = url.pathComponents[3]
                let token = url.pathComponents[4]
                
                guard let organization = UUID(uuidString: orgID) else { return }
                let request = OrganizationJoinRequest(
                    organizationName: orgName,
                    organizationID: organization,
                    email: userEmail,
                    password: "",
                    organizationJoinToken: token)
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
