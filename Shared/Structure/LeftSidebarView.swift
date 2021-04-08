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


    var body: some View {
        List {
            Section(header: Text("Apps")) {
                ForEach(api.apps.sorted { $0.name < $1.name }) { app in
                    DisclosureGroup(
                        content: {
                            NavigationLink(
                                destination: LexiconView(appID: app.id),
                                label: {
                                    Label("Lexicon", systemImage: "book")
                                }
                            )
                            NavigationLink(
                                destination: SignalList(appID: app.id),
                                label: {
                                    Label("Recent Signals", systemImage: "waveform")
                                }
                            )

                            NavigationLink(
                                destination: AppEditor(appID: app.id),
                                label: {
                                    Label("App Settings", systemImage: "gear")
                                }
                            )
                        },
                        label: {
                            NavigationLink(
                                destination: AppRootView(app: app),
                                label: {
                                    Label(app.name, systemImage: "app")
                                }
                            )
                        }
                    )
                }
            }

            Section(header: Text("Organization")) {
                if let apiUser = api.user {
                    NavigationLink(destination: OrganizationSettingsView(), label: {
                        Label(apiUser.organization?.name ?? "Unknown Org", systemImage: "app.badge")
                    })

                    NavigationLink(
                        destination: UserSettingsView(),
                        label: {
                            Label("Settings", systemImage: "gear")
                        }
                    )
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
            ToolbarItemGroup {
                #if os(macOS)
                    Button(action: toggleSidebar) {
                        Image(systemName: "sidebar.left")
                            .help("Toggle Sidebar")
                    }
                    .help("Toggle the left sidebar")
                #endif

                Spacer()
                Button(action: {
                    api.create(appNamed: "New App")
                }) {
                    Label("New App", systemImage: "plus.app.fill")
                }
                .help("Create a New App")
            }
        }
    }

    #if os(macOS)
        private func toggleSidebar() {
            NSApp.keyWindow?.firstResponder?
                .tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        }
    #endif
}
