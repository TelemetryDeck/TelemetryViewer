//
//  EditorModeView.swift
//  EditorModeView
//
//  Created by Daniel Jilg on 08.10.21.
//

import DataTransferObjects
import SwiftUI

struct EditorModeView: View {
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var groupService: GroupService

    let appID: DTOv2.App.ID

    var body: some View {
        List {
            ForEach(appService.app(withID: appID)?.insightGroupIDs ?? [], id: \.self) { insightGroupID in
                Section {
                    EditorModeGroupEditor(appID: appID, insightGroupID: insightGroupID)
                } header: {
                    TinyLoadingStateIndicator(
                        loadingState: groupService.loadingState(for: insightGroupID),
                        title: groupService.group(withID: insightGroupID)?.title
                    )
                }
            }

            Button("New Insight Group") {
                groupService.create(insightGroupNamed: "New Insight Group", for: appID) { _ in
                    appService.retrieveApp(with: appID)
                }
            }
        }
        .toolbar {
            EditButton()
        }
        .navigationTitle("Edit Insights")
    }
}

struct EditorModeGroupEditor: View {
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var groupService: GroupService
    @EnvironmentObject var insightService: InsightService
    @EnvironmentObject var lexiconService: LexiconService

    let appID: DTOv2.App.ID
    let insightGroupID: DTOv2.Group.ID

    // Unused, this is just here for API compatibility with EditorView
    @State var selectedInsightID: UUID?

    var body: some View {
        ForEach(groupService.group(withID: insightGroupID)?.insightIDs ?? [], id: \.self) { insightID in
            if let insight = insightService.insight(withID: insightID) {
                linkToInsightEditor(insight: insight)
            }
        }
        .onDelete(perform: delete)

        if let group = groupService.group(withID: insightGroupID) {
            linkToGroupEditor(group: group)
                .foregroundColor(.accentColor)

            newInsightInGroupButton(group: group)
            deleteGroupButton(group: group)
        }
    }

    func delete(at offsets: IndexSet) {
        let ids = offsets.compactMap { groupService.group(withID: insightGroupID)?.insightIDs[$0] }
        for id in ids {
            insightService.delete(insightID: id) { _ in
                groupService.retrieveGroup(with: insightGroupID)
            }
        }
    }

    func linkToInsightEditor(insight: DTOv2.Insight) -> some View {
        NavigationLink(insight.title, destination: {
            EditorView(viewModel: EditorViewModel(insight: insight, appID: appID, insightService: insightService, groupService: groupService, lexiconService: lexiconService), selectedInsightID: $selectedInsightID)

        })
    }

    func linkToGroupEditor(group: DTOv2.Group) -> some View {
        NavigationLink {
            InsightGroupEditor(groupID: group.id, appID: group.appID, title: group.title, order: group.order ?? 0)
        } label: {
            Label("Edit \(group.title)", systemImage: "square.and.pencil")
        }
    }

    func newInsightInGroupButton(group: DTOv2.Group) -> some View {
        NewInsightMenu(appID: appID, selectedInsightGroupID: group.id)
    }

    func deleteGroupButton(group: DTOv2.Group) -> some View {
        Button {
            groupService.delete(insightGroupID: insightGroupID, in: appID) { _ in
                appService.retrieveApp(with: appID)
            }
        } label: {
            Label("Delete \(group.title) and all its Insights", systemImage: "trash")
        }
    }
}

struct EditorModeView_Previews: PreviewProvider {
    static var previews: some View {
        EditorModeView(appID: UUID.empty)
    }
}
