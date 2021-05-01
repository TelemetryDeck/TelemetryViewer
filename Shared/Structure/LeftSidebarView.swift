//
//  LeftSidebarView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 17.02.21.
//

import SwiftUI

struct LeftSidebarView: View {
    @EnvironmentObject var api: APIRepresentative
    @State var selectedAppID: UUID?

    #if os(macOS)
        @EnvironmentObject var appUpdater: AppUpdater
    #endif


    var body: some View {
        List {
            ForEach(api.apps.sorted { $0.name < $1.name }) { app in
                Section(header: Text(app.name)) {
                    NavigationLink(
                        destination: AppRootView(appID: app.id), tag: app.id,
                        selection: $selectedAppID,
                        label: {
                            Label("Insights", systemImage: "app")
                        }
                    )
                    
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
                }
            }
            
            Section(header: Text("Apps")) {
                if api.isLoadingApps {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
                
                ForEach(api.apps.sorted { $0.name < $1.name }) { app in
                    
                    #if os(macOS)
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
                                destination: AppRootView(appID: app.id), tag: app.id,
                                selection: $selectedAppID,
                                label: {
                                    Label(app.name, systemImage: "app")
                                }
                            )
                        }
                    )
                    #else
                    NavigationLink(
                        destination: AppRootView(appID: app.id), tag: app.id,
                        selection: $selectedAppID,
                        label: {
                            Label(app.name, systemImage: "app")
                        }
                    )
                    #endif
                }
            }

            Section(header: Text("Meta")) {
                if let apiUser = api.user {
                    #if os(iOS)
                    NavigationLink(destination: OrganizationSettingsView(), label: {
                        Label(apiUser.organization?.name ?? "Unknown Org", systemImage: "app.badge")
                    })

                    NavigationLink(
                        destination: UserSettingsView(),
                        label: {
                            Label("Settings", systemImage: "gear")
                        }
                    )
                    #endif
                    
                    NavigationLink(
                        destination: FeedbackView(),
                        label: {
                            Label("Help & Feedback", systemImage: "ladybug.fill")
                        }
                    )
                } else {
                    Label("firstName lastName", systemImage: "person.circle").redacted(reason: .placeholder)
                    Label("organization.name", systemImage: "app.badge").redacted(reason: .placeholder)
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
                        destination: AppAdminView(),
                        label: {
                            Label("Apps", systemImage: "app.badge")
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
        .navigationTitle("AppTelemetry")
        .toolbar {
            ToolbarItemGroup {
                #if os(macOS)
                    Button(action: toggleSidebar) {
                        Image(systemName: "sidebar.left")
                            .help("Toggle Sidebar")
                    }
                    .help("Toggle the left sidebar")
                
                    Spacer()
                #endif

                Button(action: {
                    api.create(appNamed: "New App") { result in
                        switch result {
                        case .failure(let error):
                            print(error)
                        case .success(let newApp):
                            selectedAppID = newApp.id
                        }
                    }
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
