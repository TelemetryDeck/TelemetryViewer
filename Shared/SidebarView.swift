//
//  SidebarView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 10.08.20.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var api: APIRepresentative
    #if os(macOS)
    @EnvironmentObject var appUpdater: AppUpdater
    #endif

    @Binding var selectedApp: TelemetryApp?
    
    var body: some View {
        List(selection: $selectedApp) {
            
            Section(header: Text("Apps")) {
                ForEach(api.apps.sorted { $0.name < $1.name }) { app in
                    
                    NavigationLink(
                        destination: AppRootView(appID: app.id),
                        label: {
                            Label(app.name, systemImage: "app")
                        })
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

                #if os(macOS)
                NavigationLink(
                    destination: AppUpdateView(),
                    label: {
                        Label(
                            appUpdater.isAppUpdateAvailable ? "Update Available!" : "Updates",
                            systemImage: appUpdater.isAppUpdateAvailable ? "info.circle.fill" : "info.circle"
                        )
                    }
                )
                #endif
            }
            
            if api.user?.organization?.isSuperOrg == true {
                Section(header: Text("Administration")) {
                    NavigationLink(
                        destination: BetaRequestsList(),
                        label: {
                            Label {
                                HStack {
                                    Text("Beta Requests")
                                    Spacer()
                                    Text("\(api.betaRequests.filter({ !$0.isFulfilled && $0.sentAt == nil }).count)")
                                        .bold()
                                        .padding(.horizontal, 8)
                                        .foregroundColor(Color.white.opacity(0.8))
                                        .background(Color.grayColor)
                                        .clipShape(Capsule())
                                }
                            } icon: {
                                Image(systemName: "airplane")
                            }
                        }
                    )

                    NavigationLink(
                        destination: OrganizationAdmin(),
                        label: {
                            Label("Organizations", systemImage: "app.badge")
                        }
                    )

                    NavigationLink(
                        destination: DebugView(),
                        label: {
                            Label("Debug", systemImage: "ladybug")
                        }
                    )

                }
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Telemetry")
        .onAppear {
            selectedApp = api.apps.first
        }
        .toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.primaryAction) {
                HStack {
                    Button(action: {
                        api.create(appNamed: "New App")
                    }) {
                        Label("New App", systemImage: "plus.app.fill")
                    }
                }
            }
        }
    }
}
