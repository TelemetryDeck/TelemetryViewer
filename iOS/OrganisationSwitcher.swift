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
        HStack {
            VStack(alignment: .leading, spacing: 0){
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
                    Text(getCurrentOrgName())
                        .tint(.primary)
                }
                .task {
                    organizations = (try? await orgService.allOrganizations()) ?? []
                }
                Text("Tap to switch organization")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "person.3")
                .foregroundStyle(Color.telemetryOrange)

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
