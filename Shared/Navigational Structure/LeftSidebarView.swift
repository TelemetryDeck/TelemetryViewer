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
    @State var newAppViewShown: Bool = false
    @State private var showingAlert = false

    /// I think I need to mainly touch the appservice, not the orgservice, right now, since that's where the bugs are, apparently.
    ///  further testing has lead me to the conclusion that I do need to update the orgservice as well lol

    #if os(macOS)
        @EnvironmentObject var updateService: UpdateService
    #endif

    @AppStorage("sidebarSelectionExpandedSections") var expandedSections: [DTOv2.App.ID: Bool]? = nil
    @AppStorage("sidebarSelection") var sidebarSelection: LeftSidebarView.Selection? = nil

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

    var body: some View {
        List {
            Section {
                if let organization = orgService.organization {
                    ForEach(organization.appIDs, id: \.self) { appID in
                        section(for: appID)
                            .task {
                                if let app = try? await appService.retrieveApp(withID: appID) {
                                    DispatchQueue.main.async {
                                        appService.appDictionary[app.id] = app
                                    }
                                }
                            }
                    }
                }
                Button {
                    newAppViewShown = true
                } label: {
                    Label("Add a new app", systemImage: "plus.square.dashed")
                }
                .sheet(isPresented: $newAppViewShown) {
                    #if os(macOS)
                        CreateNewAppView(createNewAppViewModel: .init(api: api, appService: appService, orgService: orgService, newAppViewShown: $newAppViewShown))
                    #else
                        NavigationView {
                            CreateNewAppView(createNewAppViewModel: .init(api: api, appService: appService, orgService: orgService, newAppViewShown: $newAppViewShown))
                        }
                    #endif
                }

            } header: {
                Text("Apps")
            }

            Section {
                LoadingStateIndicator(loadingState: orgService.loadingState, title: orgService.organization?.name)

                #if os(iOS)
                    Button {
                        URL(string: "https://dashboard.telemetrydeck.com/user/profile")!.open()
                    } label: {
                        Label("Organization Settings", systemImage: "app.badge")
                    }

                    if api.user != nil {
                        Button {
                            URL(string: "https://dashboard.telemetrydeck.com/user/organization")!.open()
                        } label: {
                            Label("User Settings", systemImage: "gear")
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

                NavigationLink(tag: Selection.editApp(app: app.id), selection: $sidebarSelection) {
                    AppEditor(appID: app.id, appName: app.name)
                } label: {
                    Label("Edit App", systemImage: "square.and.pencil")
                }
                .tag(Selection.editApp(app: appID))

            } else {
                TinyLoadingStateIndicator(loadingState: appService.loadingStateDictionary[appID] ?? .idle, title: "Insights")
                TinyLoadingStateIndicator(loadingState: appService.loadingStateDictionary[appID] ?? .idle, title: "Signal Types")
                TinyLoadingStateIndicator(loadingState: appService.loadingStateDictionary[appID] ?? .idle, title: "Recent Signals")
                TinyLoadingStateIndicator(loadingState: appService.loadingStateDictionary[appID] ?? .idle, title: "Edit App")
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
