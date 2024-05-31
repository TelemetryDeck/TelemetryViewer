//
//  LeftSidebarView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 17.02.21.
//

import DataTransferObjects
import SwiftUI

struct LeftSidebarView: View {
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var orgService: OrgService
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var groupService: GroupService
    @EnvironmentObject var insightService: InsightService
    @State private var showingAlert = false

    #if os(macOS)
        @EnvironmentObject var updateService: UpdateService
    #endif

    // swiftlint:disable redundant_optional_initialization
    @AppStorage("sidebarSelectionExpandedSections") var expandedSections: [DTOv2.App.ID: Bool]? = nil
    @AppStorage("sidebarSelection") var sidebarSelection: LeftSidebarView.Selection? = nil
    // swiftlint:enable redundant_optional_initialization

    enum Selection: Codable, Hashable {
        case getStarted
        case plansAndPricing
        case feedback
        case newApp
        case insights(app: UUID)
        case signalTypes(app: UUID)
        case recentSignals(app: UUID)
        case editApp(app: UUID)
    }

    func getApps(organization: DTOv2.Organization?) {
        Task {
            for appID in organization?.appIDs ?? [] {
                if let app = try? await appService.retrieveApp(withID: appID) {
                    DispatchQueue.main.async {
                        app.insightGroupIDs.forEach { groupID in
                            if !(groupService.groupsDictionary.keys.contains(groupID)) {
                                groupService.retrieveGroup(with: groupID)
                            }
                        }
                        appService.appDictionary[app.id] = app
                    }
                }
            }
        }
    }

    var body: some View {
        List {
            Section {
                if let organization = orgService.organization {
                    ForEach(organization.appIDs, id: \.self) { appID in
                        section(for: appID)
                    }
                    .onChange(of: orgService.organization) {
                        getApps(organization: orgService.organization)
                    }
                    .task {
                        getApps(organization: orgService.organization)
                    }
                }

            } header: {
                Text("Apps")
            }

            Section {
                OrganisationSwitcher()

                #if os(iOS)
                    Button {
                        URL(string: "https://dashboard.telemetrydeck.com/user/organization")!.open()
                    } label: {
                        HStack {
                            Label("Organization Settings", systemImage: "app.badge")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.gray)
                        }
                    }

                    if api.user != nil {
                        Button {
                            URL(string: "https://dashboard.telemetrydeck.com/user/profile")!.open()
                        } label: {
                            HStack {
                                Label("User Settings", systemImage: "gear")
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                #endif

                NavigationLink(tag: Selection.feedback, selection: $sidebarSelection) {
                    FeedbackView()
                } label: {
                    Label("Help & Feedback", systemImage: "ladybug.fill")
                }

                Button {
                    showingAlert = true
                } label: {
                    Label("Log Out \(api.user?.firstName ?? "User")", systemImage: "rectangle.portrait.and.arrow.right")
                }
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("Really Log Out?"),
                        message: Text("You can log back in again later"),
                        primaryButton: .destructive(Text("Log Out")) {
                            api.logout()
                            orgService.organization = nil
                            appService.appDictionary = [:]
                            groupService.groupsDictionary = [:]
                            insightService.insightDictionary = [:]
                        },
                        secondaryButton: .cancel()
                    )
                }
            } header: {
                Text("Meta")
            }
        }
        .task {
            if let organization = try? await orgService.retrieveOrganisation() {
                DispatchQueue.main.async {
                    orgService.organization = organization
                    orgService.getOrganisation()
                }
            }
        }

        #if os(macOS)
            .sheet(isPresented: $updateService.shouldShowUpdateNowScreen) {
                AppUpdateView()
            }
        #endif
        .navigationTitle("TelemetryDeck")
            .listStyle(.sidebar)
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
                }
            }
    }

    private func binding(for key: DTOv2.App.ID) -> Binding<Bool> {
        return .init(
            get: { self.expandedSections?[key] ?? false },
            set: {
                if self.expandedSections == nil {
                    self.expandedSections = [:]
                }
                self.expandedSections?[key] = $0
            }
        )
    }

    func section(for appID: DTOv2.App.ID) -> some View {
        DisclosureGroup(isExpanded: self.binding(for: appID)) {
            if let app = appService.appDictionary[appID] {
                NavigationLink(tag: Selection.insights(app: app.id), selection: $sidebarSelection) {
                    InsightGroupsView(appID: app.id)
                } label: {
                    Label("Insights", systemImage: "chart.bar.xaxis")
                }
                .tag(Selection.insights(app: appID))

                NavigationLink(tag: Selection.signalTypes(app: app.id), selection: $sidebarSelection) {
                    LexiconView(appID: app.id)
                } label: {
                    Label("Signal Types", systemImage: "book")
                }
                .tag(Selection.signalTypes(app: appID))

                NavigationLink(tag: Selection.recentSignals(app: app.id), selection: $sidebarSelection) {
                    SignalList(appID: app.id)
                } label: {
                    Label("Recent Signals", systemImage: "list.triangle")
                }
                .tag(Selection.recentSignals(app: appID))

            } else {
                TinyLoadingStateIndicator(loadingState: appService.loadingStateDictionary[appID] ?? .idle, title: "Insights")
                TinyLoadingStateIndicator(loadingState: appService.loadingStateDictionary[appID] ?? .idle, title: "Signal Types")
                TinyLoadingStateIndicator(loadingState: appService.loadingStateDictionary[appID] ?? .idle, title: "Recent Signals")
            }
        } label: {
            LabelLoadingStateIndicator(loadingState: appService.loadingStateDictionary[appID] ?? .idle, title: appService.appDictionary[appID]?.name, systemImage: "sensor.tag.radiowaves.forward")
        }
    }

    #if os(macOS)
        private func toggleSidebar() {
            NSApp.keyWindow?.firstResponder?
                .tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        }
    #endif
}
