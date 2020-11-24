//
//  OrganizationSettingsView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 07.09.20.
//

import SwiftUI
import TelemetryClient

struct UserInfoView: View {
    var user: UserDataTransferObject
    
    var body: some View {
        VStack {
            Text(user.firstName)
            Text(user.lastName)
            Text(user.email)
            Text(user.isFoundingUser ? "Founding User" : "")
        }
    }
}

struct OrganizationSettingsView: View {
    @EnvironmentObject var api: APIRepresentative
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var sizeClass
    #else
    enum SizeClassNoop {
        case compact
        case notCompact
    }
    
    var sizeClass: SizeClassNoop = .notCompact
    #endif
    
    @State private var selectedItem: OrganizationJoinRequest?
    @State private var sidebarShown: Bool = false
    
    var body: some View {
        HStack {
            List {
                Section(header: Text("Organization Users")) {
                    ForEach(api.organizationUsers) { organizationUser in
                        NavigationLink(destination: UserInfoView(user: organizationUser)) {
                            HStack {
                                Text(organizationUser.firstName)
                                Text(organizationUser.lastName)
                                Text(organizationUser.email)
                                Spacer()
                                Text(organizationUser.isFoundingUser ? "Founding User" : "")
                            }
                        }
                    }
                }
                
                Section(header: Text("Join Requests")) {
                    ForEach(api.organizationJoinRequests) { joinRequest in
                        #if os(iOS)
                        if sizeClass == .compact {
                            NavigationLink(destination: CreateOrganizationJoinRequestView(organizationJoinRequest: .constant(joinRequest))) {
                                Text(joinRequest.registrationToken)
                            }
                        } else {
                            ListItemView(background: joinRequest == selectedItem ? Color.accentColor : Color.grayColor.opacity(0.2)) {
                                Text(joinRequest.registrationToken)
                                Spacer()
                            }.onTapGesture {
                                selectedItem = joinRequest
                                withAnimation {
                                    sidebarShown = true
                                }
                            }
                        }
                        #else
                        ListItemView(selected: joinRequest == selectedItem && sidebarShown) {
                            Text(joinRequest.registrationToken)
                            Spacer()
                        }.onTapGesture {
                            selectedItem = joinRequest
                            withAnimation {
                                sidebarShown = true
                            }
                        }
                        #endif
                    }
                    
                    Button("Create an Invitation to Join \(api.user?.organization?.name ?? "noorg")") {
                        api.createOrganizationJoinRequest()
                    }
                }
            }
            .frame(minWidth: sizeClass == .compact ? 0 : 450)
            
            
            
            
            if sidebarShown {
                DetailSidebar(isOpen: $sidebarShown, maxWidth: 400) {
                    CreateOrganizationJoinRequestView(organizationJoinRequest: $selectedItem)
                }.transition(.move(edge: .trailing))
            }
            
        }
        .onAppear {
            TelemetryManager.shared.send(TelemetrySignal.organizationSettingsShown.rawValue, for: api.user?.email)
            api.getOrganizationUsers()
            api.getOrganizationJoinRequests()
        }
        .navigationTitle("Organization Settings – \(api.user?.organization?.name ?? "noorg")")
        
    }
}

struct OrganizationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        OrganizationSettingsView().environmentObject(APIRepresentative())
    }
}
