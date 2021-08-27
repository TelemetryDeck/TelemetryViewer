//
//  LeftSidebarView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 17.02.21.
//

import SwiftUI

enum LeftSidebarViewSelection {
    case gettingStarted
    case insights
    case lexicon
    case signalTypes
    case payloads
    case recentSignals
    case appSettings
    case helpAndFeedback
}

struct LeftSidebarView: View {
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var orgService: OrgService
    @EnvironmentObject var appService: AppService
    @State var selection: LeftSidebarViewSelection? = .insights
    
    var body: some View {
        List {
            LoadingStateIndicator(loadingState: orgService.loadingState, title: orgService.organization?.name)
            
            if let organization = orgService.organization {   
                ForEach(organization.appIDs, id: \.self) { appID in
                    section(for: appID)
                }
            }
            
            Section(header: Text("Meta")) {
                #if os(iOS)
                    NavigationLink(destination: OrganizationSettingsView(), label: {
                        Label(api.user?.organization?.name ?? "Organization Settings", systemImage: "app.badge")
                    })
                
                if let user = api.user {
                    NavigationLink(
                        destination: UserSettingsView(userDTO: user),
                        label: {
                            Label("\(api.user?.firstName ?? "User") \(api.user?.lastName ?? "Settings")", systemImage: "gear")
                        }
                    )
                }
                #endif

                NavigationLink(
                    destination: FeedbackView(),
                    label: {
                        Label("Help & Feedback", systemImage: "ladybug.fill")
                    }
                )
            }
            
        }
        .listStyle(.sidebar)
    }
    
    func section(for appID: DTOsWithIdentifiers.App.ID) -> some View {
        Section {
            if let app = appService.app(withID: appID) {
                if let first = app.insightGroupIDs.first {
                    NavigationLink { InsightGroupsView(selectedInsightGroupID: first, appID: app.id) } label: { Label(app.name, systemImage: "app") }
                }
            } else {
                TinyLoadingStateIndicator(loadingState: appService.loadingState(for: appID), title: appService.app(withID: appID)?.name)
            }
        } header: {
            TinyLoadingStateIndicator(loadingState: appService.loadingState(for: appID), title: appService.app(withID: appID)?.name)
        }
    }
}

struct OldLeftSidebarView: View {
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var appService: OldAppService
    @State var selection: LeftSidebarViewSelection? = .insights

    #if os(macOS)
        @EnvironmentObject var updateService: UpateService
    #endif

    var body: some View {
        List {
            if appService.getTelemetryApps().isEmpty {
                Text("Hint: Click the + Button")
                    .font(.footnote)

                NavigationLink(destination: AppInfoView()) {
                    Label("Get Started", systemImage: "mustache.fill")
                }
            }

            if let app = appService.getSelectedApp() {
                Picker(selection: $appService.selectedAppID, label: EmptyView()) {
                    ForEach(appService.getTelemetryApps()) { app in
                        Text(app.name)
                            .foregroundColor(.customTextColor)
                            .tag(app.id as UUID?)
                    }
                }
                .onChange(of: appService.selectedAppID) { _ in selection = .insights }

                Section(header: Text(app.name)) {
                    NavigationLink(
                        destination: AppRootView(appID: app.id),
                        tag: LeftSidebarViewSelection.insights,
                        selection: $selection,
                        label: {
                            Label("Insights", systemImage: "app")
                        }
                    )

                    #if os(macOS)
                        if #available(macOS 12, *) {
                            NavigationLink(
                                destination: MacOs12SignalTypesView(appID: app.id),
                                tag: LeftSidebarViewSelection.signalTypes,
                                selection: $selection,
                                label: {
                                    Label("Signal Types", systemImage: "book")
                                }
                            )
                            NavigationLink(
                                destination: MacOs12PayloadKeysView(appID: app.id),
                                tag: LeftSidebarViewSelection.payloads,
                                selection: $selection,
                                label: {
                                    Label("Payloads", systemImage: "book")
                                }
                            )
                        } else {
                            NavigationLink(
                                destination: LexiconView(appID: app.id),
                                tag: LeftSidebarViewSelection.lexicon,
                                selection: $selection,
                                label: {
                                    Label("Signal Types", systemImage: "book")
                                }
                            )
                        }

                        if #available(macOS 12, *) {
                            NavigationLink(
                                destination: MacOs12RecentSignalsView(appID: app.id),
                                tag: LeftSidebarViewSelection.recentSignals,
                                selection: $selection,
                                label: {
                                    Label("Recent Signals", systemImage: "waveform")
                                }
                            )
                        } else {
                            NavigationLink(
                                destination: SignalList(appID: app.id),
                                tag: LeftSidebarViewSelection.recentSignals,
                                selection: $selection,
                                label: {
                                    Label("Recent Signals", systemImage: "waveform")
                                }
                            )
                        }

                    #else

                        NavigationLink(
                            destination: LexiconView(appID: app.id),
                            tag: LeftSidebarViewSelection.lexicon,
                            selection: $selection,
                            label: {
                                Label("Signal Types", systemImage: "book")
                            }
                        )

                        NavigationLink(
                            destination: SignalList(appID: app.id),
                            tag: LeftSidebarViewSelection.recentSignals,
                            selection: $selection,
                            label: {
                                Label("Recent Signals", systemImage: "waveform")
                            }
                        )
                    #endif

                    NavigationLink(
                        destination: AppEditor(appID: app.id, appName: app.name),
                        tag: LeftSidebarViewSelection.appSettings,
                        selection: $selection,
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
                
                if let user = api.user {
                    NavigationLink(
                        destination: UserSettingsView(userDTO: user),
                        label: {
                            Label("\(api.user?.firstName ?? "User") \(api.user?.lastName ?? "Settings")", systemImage: "gear")
                        }
                    )
                }
                #endif

                NavigationLink(
                    destination: FeedbackView(),
                    label: {
                        Label("Help & Feedback", systemImage: "ladybug.fill")
                    }
                )
            }
        }
        .sheet(isPresented: $api.needsDecisionForMarketingEmails, content: {
            AskForMarketingEmailsView()
        })
        .listStyle(SidebarListStyle())
        #if os(macOS)
            .sheet(isPresented: $updateService.shouldShowUpdateNowScreen) {
                AppUpdateView()
            }
        #endif
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
                        appService.create(appNamed: "New App") { result in
                            switch result {
                            case .failure(let error):
                                print(error)
                            case .success(let newApp):
                                appService.selectedAppID = newApp.id
                                selection = .appSettings
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
