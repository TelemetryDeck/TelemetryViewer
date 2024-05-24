//
//  InsightGroupsView.swift
//  InsightGroupsView
//
//  Created by Daniel Jilg on 18.08.21.
//

import DataTransferObjects
import SwiftUI
import TelemetryClient

/// Show insight groups and insights
///
/// This view contains a NavigationView despite being included in a navigation stack already. This is a workaround, because otherwise
/// the bottom bar wouldn't get displayed correctly on iOS 16. To prevent the double Navigation Bar showing, we're hiding one of the
/// bars using a newly created view modifier. We feel slightly dirty after writing this and hope to remove it at some glorious future day.
struct InsightGroupsView: View {
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var groupService: GroupService
    @EnvironmentObject var queryService: QueryService
    @EnvironmentObject var insightService: InsightService

    @State var sidebarVisible = false
    @State var selectedInsightGroupID: DTOv2.Group.ID?
    @State var selectedInsightID: DTOv2.Insight.ID?
    @State private var showDatePicker: Bool = false

    @Environment(\.horizontalSizeClass) var sizeClass

    private var groupsToolbarPlacement: ToolbarItemPlacement {
        if sizeClass == .compact {
            return .bottomBar
        } else {
            return .navigation
        }
    }

    let appID: DTOv2.App.ID

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                //StatusMessageDisplay()

                TestModeIndicator()

                groupSelector
                    .padding(.horizontal)
                    .padding(.bottom)

                Divider()

                Group {
                    if selectedInsightGroupID == nil {
                        EmptyAppView(appID: appID)
                            .frame(maxWidth: 400)
                            .padding()
                    }

                    selectedInsightGroupID.map {
                        GroupView(groupID: $0, selectedInsightID: $selectedInsightID, sidebarVisible: $sidebarVisible)
                            .background(Color.separatorColor)
                    }
                }
            }

            .alwaysHideNavigationBar()
            .onAppear {
                selectedInsightGroupID = appService.app(withID: appID)?.insightGroupIDs.first
                TelemetryManager.send("InsightGroupsAppear")
            }
            .task {
                for groupID in groupService.groupsDictionary.keys {
                    for insightID in groupService.groupsDictionary[groupID]?.insightIDs ?? [] {
                        if !(insightService.insightDictionary.keys.contains(insightID)) {
                            await insightService.retrieveInsight(with: insightID)
                        }
                    }
                }
            }
            .onReceive(groupService.objectWillChange) { _ in
                if let groupID = selectedInsightGroupID {
                    if !(groupService.groupsDictionary.keys.contains(groupID)) {
                        selectedInsightGroupID = appService.appDictionary[appID]?.insightGroupIDs.first
                    }
                } else {
                    selectedInsightGroupID = appService.appDictionary[appID]?.insightGroupIDs.first
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Toggle("Test Mode", isOn: $queryService.isTestingMode.animation())
                    datePickerButton
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(appService.app(withID: appID)?.name ?? "Loading...")
        .navigationViewStyle(.stack)
    }

    private var groupSelector: some View {
        Picker("Group", selection: $selectedInsightGroupID) {
            if let app = appService.app(withID: appID) {
                ForEach(
                    app.insightGroupIDs
                        .map { ($0, groupService.group(withID: $0)?.order ?? 0) }
                        .sorted(by: { $0.1 < $1.1 }),
                    id: \.0
                ) { idTuple in
                    TinyLoadingStateIndicator(
                        loadingState: groupService.loadingState(for: idTuple.0),
                        title: groupService.group(withID: idTuple.0)?.title
                    )
                    .tag(idTuple.0 as DTOv2.Group.ID?)
                }
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }

    private var datePickerButton: some View {
        Button(queryService.timeIntervalDescription) {
            TelemetryManager.send("showDatePicker")
            self.showDatePicker = true
        }.popover(
            isPresented: self.$showDatePicker,
            arrowEdge: .bottom
        ) { InsightDataTimeIntervalPicker().padding() }
    }

    private var newGroupButton: some View {
        Button {
            groupService.create(insightGroupNamed: "New Group", for: appID) { _ in
                Task {
                    if let app = try? await appService.retrieveApp(withID: appID) {
                        DispatchQueue.main.async {
                            appService.appDictionary[appID] = app
                            appService.app(withID: appID)?.insightGroupIDs.forEach { groupID in
                                groupService.retrieveGroup(with: groupID)
                            }
                        }
                    }
                }
            }
        } label: {
            Label("New Group", systemImage: "plus")
        }
    }
}

@available(iOS 16, *)
struct WithoutNavigationBarIOS16: ViewModifier {
    func body(content: Content) -> some View {
        content.toolbar(.hidden, for: .navigationBar)
    }
}

struct WithoutNavigationBarLegacy: ViewModifier {
    func body(content: Content) -> some View {
        content.navigationBarHidden(true)
    }
}

extension View {
    func alwaysHideNavigationBar() -> some View {
        if #available(iOS 16, *) {
            return modifier(WithoutNavigationBarIOS16())
        } else {
            return modifier(WithoutNavigationBarLegacy())
        }
    }
}
