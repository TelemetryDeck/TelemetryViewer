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
        @EnvironmentObject var updateService: UpateService
    #endif

    var body: some View {
        List {
            if api.apps.isEmpty {
                Text("Hint: Click the + Button")
                    .font(.footnote)

                NavigationLink(destination: AppInfoView()) {
                    Label("Get Started", systemImage: "mustache.fill")
                }
            }

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

            Section(header: Text("Meta")) {
                #if os(iOS)
                    NavigationLink(destination: OrganizationSettingsView(), label: {
                        Label(api.user?.organization?.name ?? "Organization Settings", systemImage: "app.badge")
                    })

                    NavigationLink(
                        destination: UserSettingsView(),
                        label: {
                            Label("\(api.user?.firstName ?? "User") \(api.user?.lastName ?? "Settings")", systemImage: "gear")
                        }
                    )
                #endif
                
                NavigationLink(
                    destination: FeedbackView(),
                    label: {
                        Label("Help & Feedback", systemImage: "ladybug.fill")
                    }
                )
            }

            if api.user?.organization?.isSuperOrg == true {
                Section(header: Text("Administration")) {
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
        .sheet(isPresented: $api.needsDecisionForMarketingEmails, content: {
            AskForMarketingEmailsView()
        })
        .listStyle(SidebarListStyle())
        .modify {
            #if os(macOS)
                $0.sheet(isPresented: $updateService.shouldShowUpdateNowScreen) {
                    AppUpdateView()
                }
            #else
                $0
            #endif
        }
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
