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
            if api.apps.count > 0 {
                Text("Please Select an App")
                    .foregroundColor(.grayColor)
            } else {
                VStack(spacing: 20) {
                    Text("Welcome to Telemetry!")
                        .font(.title)
                        .foregroundColor(.grayColor)

                    Image(systemName: "app.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.grayColor)

                    Text("To start, create your first App. You can use that App's unique identifier to send signals from your code.")
                        .foregroundColor(.grayColor)
                    VStack {
                        Button("Create First App") {
                            api.create(appNamed: "New App")
                        }
                        .buttonStyle(SmallPrimaryButtonStyle())

                        Button("Documentation: Sending Signals") {
                            #if os(macOS)
                            NSWorkspace.shared.open(URL(string: "https://apptelemetry.io/pages/quickstart.html")!)
                            #else
                            UIApplication.shared.open(URL(string: "https://apptelemetry.io/pages/quickstart.html")!)
                            #endif
                        }
                        .buttonStyle(SmallSecondaryButtonStyle())
                    }
                }
                .frame(maxWidth: 400)
            }
                
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
