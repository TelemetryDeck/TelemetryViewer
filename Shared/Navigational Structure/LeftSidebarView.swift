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
    @State var newAppViewShown: Bool = false

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
                    
                    NavigationLink(destination: CreateNewAppView(createNewAppViewModel: .init(api: api, appService: appService, orgService: orgService, newAppViewShown: $newAppViewShown)), isActive: $newAppViewShown, label: {
                        Text("Add app")
                        Image(systemName: "plus.square.dashed")
                            .help("Add App")
                    })
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
                TinyLoadingStateIndicator(loadingState: appService.loadingState(for: appID), title: "Insights")
                TinyLoadingStateIndicator(loadingState: appService.loadingState(for: appID), title: "Signal Types")
                TinyLoadingStateIndicator(loadingState: appService.loadingState(for: appID), title: "Recent Signals")
                TinyLoadingStateIndicator(loadingState: appService.loadingState(for: appID), title: "Edit App")
            }
        } label: {
            LabelLoadingStateIndicator(loadingState: appService.loadingState(for: appID), title: appService.app(withID: appID)?.name, systemImage: "sensor.tag.radiowaves.forward")
        }
    }

    #if os(macOS)
        private func toggleSidebar() {
            NSApp.keyWindow?.firstResponder?
                .tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        }
    #endif
}
