//
//  OrganizationSettingsView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 07.09.20.
//

import SwiftUI
import TelemetryClient
import DataTransferObjects

struct UserInfoView: View {
    var user: DTOv1.UserDTO

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
    @EnvironmentObject var api: APIClient

    #if os(iOS)
        @Environment(\.horizontalSizeClass) var sizeClass
    #else
        enum SizeClassNoop {
            case compact
            case notCompact
        }

        var sizeClass: SizeClassNoop = .notCompact
    #endif

    @State private var showingSheet = false
    @State private var isLoadingOrganizationJoinRequests: Bool = false
    @State private var isLoadingOrganizationUsers: Bool = false

    var body: some View {
        VStack {
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

                        ListItemView {
                            Text(joinRequest.email)
                            Spacer()
                            Text(joinRequest.registrationToken)

                            Button(action: {
                                api.delete(organizationJoinRequest: joinRequest)
                            }, label: {
                                Image(systemName: "minus.circle.fill")
                            })
                                .buttonStyle(IconButtonStyle())
                        }
                    }

                    Button("Create an Invitation to Join \(api.user?.organization?.name ?? "noorg")") {
                        showingSheet.toggle()
                    }
                    .buttonStyle(SmallSecondaryButtonStyle())
                }
            }
        }
        .navigationTitle(api.user?.organization?.name ?? "Organization")
        .onAppear {
            TelemetryManager.shared.send(TelemetrySignal.organizationSettingsShown.rawValue, for: api.user?.email)
            isLoadingOrganizationUsers = true
            api.getOrganizationUsers { _ in
                isLoadingOrganizationUsers = false
            }

            isLoadingOrganizationJoinRequests = true
            api.getOrganizationJoinRequests { _ in
                isLoadingOrganizationJoinRequests = false
            }
        }
        .sheet(isPresented: $showingSheet) {
            CreateOrganizationJoinRequestView()
        }
    }
}

struct OrganizationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        OrganizationSettingsView().environmentObject(APIClient())
    }
}
