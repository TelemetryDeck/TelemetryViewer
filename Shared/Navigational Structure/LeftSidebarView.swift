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

    #if os(macOS)
        @EnvironmentObject var updateService: UpdateService
    #endif

    @AppStorage("sidebarSelectionExpandedSections") var expandedSections: [DTOv2.App.ID: Bool]? = nil
    @AppStorage("sidebarSelection") var sidebarSelection: LeftSidebarView.Selection? = nil

    enum Selection: Codable, Hashable {
        case getStarted
        case plansAndPricing
        case feedback
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
                    }

                    if organization.appIDs.isEmpty {
                        NavigationLink(tag: Selection.getStarted, selection: $sidebarSelection) {
                            NoAppSelectedView()
                        } label: {
                            Label("Get Started", systemImage: "mustache.fill")
                        }
                    }
                }
            } header: {
                Text("Apps")
            }

            Section {
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

                NavigationLink(tag: Selection.feedback, selection: $sidebarSelection) {
                    FeedbackView()
                } label: {
                    Label("Help & Feedback", systemImage: "ladybug.fill")
                }

                LoadingStateIndicator(loadingState: orgService.loadingState, title: orgService.organization?.name)

            } header: {
                Text("Meta")
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

                    Button(action: {
                        appService.create(appNamed: "New App") { result in
                            switch result {
                            case .failure(let error):
                                print(error)
                            case .success:
                                print("done")
                            }
                        }
                    }) {
                        Label("New App", systemImage: "plus.app.fill")
                    }
                    .help("Create a New App")
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
            if let app = appService.app(withID: appID) {
                NavigationLink(tag: Selection.insights(app: app.id), selection: $sidebarSelection) {
                    InsightGroupsView(appID: app.id)
                } label: {
                    Label("Insights", systemImage: "chart.bar.xaxis")
                }

                NavigationLink(tag: Selection.signalTypes(app: app.id), selection: $sidebarSelection) {
                    LexiconView(appID: app.id)
                } label: {
                    Label("Signal Types", systemImage: "book")
                }

                NavigationLink(tag: Selection.recentSignals(app: app.id), selection: $sidebarSelection) {
                    SignalList(appID: app.id)
                } label: {
                    Label("Recent Signals", systemImage: "list.triangle")
                }

                NavigationLink(tag: Selection.editApp(app: app.id), selection: $sidebarSelection) {
                    AppEditor(appID: app.id, appName: app.name)
                } label: {
                    Label("Edit App", systemImage: "square.and.pencil")
                }

            } else {
                TinyLoadingStateIndicator(loadingState: appService.loadingState(for: appID), title: "Insights")
                TinyLoadingStateIndicator(loadingState: appService.loadingState(for: appID), title: "Signal Types")
                TinyLoadingStateIndicator(loadingState: appService.loadingState(for: appID), title: "Recent Signals")
                TinyLoadingStateIndicator(loadingState: appService.loadingState(for: appID), title: "Edit App")
            }
        } label: {
            LabelLoadingStateIndicator(loadingState: appService.loadingState(for: appID), title: appService.app(withID: appID)?.name, systemImage: "app")
        }
    }

    #if os(macOS)
        private func toggleSidebar() {
            NSApp.keyWindow?.firstResponder?
                .tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        }
    #endif
}
