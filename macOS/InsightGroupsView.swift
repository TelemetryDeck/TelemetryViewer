//
//  InsightGroupsView.swift
//  InsightGroupsView
//
//  Created by Daniel Jilg on 18.08.21.
//

import DataTransferObjects
import SwiftUI
import TelemetryClient

struct InsightGroupsView: View {
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var groupService: GroupService
    @EnvironmentObject var queryService: QueryService

    @State var sidebarVisible = false
    @State var selectedInsightGroupID: DTOv2.Group.ID?
    @State var selectedInsightID: DTOv2.Insight.ID?
    @State private var showDatePicker: Bool = false

    private var groupsToolbarPlacement: ToolbarItemPlacement {
        return .navigation
    }

    let appID: DTOv2.App.ID

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Group {
                if selectedInsightGroupID == nil {
                    EmptyAppView(appID: appID)
                        .frame(maxWidth: 400)
                        .padding()
                }

                selectedInsightGroupID.map {
                    GroupView(groupID: $0, selectedInsightID: $selectedInsightID, sidebarVisible: $sidebarVisible)
                }
            }
        }
        .onAppear {
            appService.appDictionary[appID]?.insightGroupIDs.forEach { groupID in
                groupService.retrieveGroup(with: groupID)
            }
            selectedInsightGroupID = appService.appDictionary[appID]?.insightGroupIDs.first
            TelemetryManager.send("InsightGroupsAppear")
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

        .navigationTitle(appService.app(withID: appID)?.name ?? "Loading...")
        .toolbar {
            ToolbarItemGroup(placement: groupsToolbarPlacement) {
                groupSelector
                newGroupButton
            }

            ToolbarItem {
                Button(queryService.timeIntervalDescription) {
                    TelemetryManager.send("showDatePicker")
                    self.showDatePicker = true
                }.popover(
                    isPresented: self.$showDatePicker,
                    arrowEdge: .bottom
                ) { InsightDataTimeIntervalPicker().padding() }
            }

            ToolbarItem {
                TestingModeToggle()
            }

            ToolbarItem {
                if let selectedInsightGroupID = selectedInsightGroupID {
                    NewInsightMenu(appID: appID, selectedInsightGroupID: selectedInsightGroupID)
                }
            }

            ToolbarItem {
                sidebarToggleButton
            }
        }
    }

    private var sidebarToggleButton: some View {
        Button {
            TelemetryManager.send("InsightGroupsSidebarToggle")

            withAnimation {
                sidebarVisible.toggle()
                selectedInsightID = nil
            }
        } label: {
            Image(systemName: "sidebar.right")
        }
        .help("Toggle right sidebar")
    }

    private var groupSelector: some View {
        Picker("Group", selection: $selectedInsightGroupID) {
            if let app = appService.appDictionary[appID] {
                ForEach(
                    app.insightGroupIDs
                        .map { ($0, groupService.groupsDictionary[$0]?.order ?? 0) }
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

    private var newGroupButton: some View {
        Button(action: {
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
        }) {
            HStack {
                Image(systemName: "plus")
                Text("New Group")
            }
        }
    }
}
