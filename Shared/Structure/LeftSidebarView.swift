//
//  LeftSidebarView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 17.02.21.
//

import SwiftUI

struct LeftSidebarView: View {
    @EnvironmentObject var api: APIRepresentative

    #if os(macOS)
    @EnvironmentObject var appUpdater: AppUpdater
    #endif

    @State private var isDefaultItemActive = true

    var body: some View {
        List {
            Section(header: Text("Apps")) {
                ForEach(api.apps.sorted { $0.name < $1.name }) { app in

                    NavigationLink(
                        destination: AppRootView(app: app),
                        label: {
                            Label(app.name, systemImage: "app")
                        }
                    )
                }
            }

            Section(header: Text("You")) {
                if let apiUser = api.user {
                    NavigationLink(destination: UserSettingsView(), label: {
                        Label("\(apiUser.firstName) \(apiUser.lastName)", systemImage: "person.circle")
                    })

                    NavigationLink(destination: OrganizationSettingsView(), label: {
                        Label(apiUser.organization?.name ?? "Unknown Org", systemImage: "app.badge")
                    })
                } else {
                    Label("firstName lastName", systemImage: "person.circle").redacted(reason: .placeholder)
                    Label("organization.name", systemImage: "app.badge").redacted(reason: .placeholder)
                }
            }

            #if os(macOS)
            Section(header: Text("App Updates")) {
                NavigationLink(
                    destination: AppUpdateView(),
                    label: {
                        Label(
                            appUpdater.isAppUpdateAvailable ? "Update Available!" : "Updates",
                            systemImage: appUpdater.isAppUpdateAvailable ? "info.circle.fill" : "info.circle"
                        )
                    }
                )
            }
            #endif

            if api.user?.organization?.isSuperOrg == true {
                Section(header: Text("Administration")) {
                    NavigationLink(
                        destination: BetaRequestsList(),
                        label: {
                            Label("Beta Requests", systemImage: "airplane")
                        }
                    )

                    NavigationLink(
                        destination: InsightQueryAdmin(),
                        label: {
                            Label("Insights", systemImage: "app.badge")
                        }
                    )
                }
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Telemetry")
        .toolbar {
            Spacer()
            Button(action: {
                api.create(appNamed: "New App")
            }) {
                Label("New App", systemImage: "plus.app.fill")
            }
        }
    }
}
