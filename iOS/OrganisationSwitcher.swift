//
//  OrganisationSwitcher.swift
//  Telemetry Viewer
//
//  Created by Lukas on 29.05.24.
//

import SwiftUI
import DataTransferObjects

struct OrganisationSwitcher: View {
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var orgService: OrgService

    @State var organizations: [OrganizationInfo] = []

    var body: some View {
            Menu {
                ForEach(organizations, id: \.id) { org in
                    Button(action: {
                        api._currentOrganisationID = org.id.uuidString
                        orgService.getOrganisation()
                    }, label: {
                        Text(org.name)
                    })
                }
            } label: {
                Label(getCurrentOrgName(), systemImage: "plus")
            }
            .task {
                print("Hello World")
                organizations = (try? await orgService.allOrganizations()) ?? []
            }
    }

    func getCurrentOrgName() -> String{
        let org = organizations.first { org in
            org.id.uuidString == api._currentOrganisationID
        }
        return org?.name ?? organizations.first?.name ?? "No Data"
    }
}

#Preview {
    OrganisationSwitcher()
}
