//
//  EditorModeView.swift
//  EditorModeView
//
//  Created by Daniel Jilg on 08.10.21.
//

import SwiftUI

struct EditorModeView: View {
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var groupService: GroupService
    @EnvironmentObject var insightService: InsightService
    @EnvironmentObject var lexiconService: LexiconService

    // Unused, this is just here for API compatibility with EditorView
    @State var selectedInsightID: UUID?

    let appID: DTOv2.App.ID

    var body: some View {
        List {
            ForEach(appService.app(withID: appID)?.insightGroupIDs ?? [], id: \.self) { insightGroupID in
                Section {
                    ForEach(groupService.group(withID: insightGroupID)?.insightIDs ?? [], id: \.self) { insightID in
                        if let insight = insightService.insight(withID: insightID) {
                            linkToEditor(insight: insight)
                        }
                    }

                } header: {
                    TinyLoadingStateIndicator(
                        loadingState: groupService.loadingState(for: insightGroupID),
                        title: groupService.group(withID: insightGroupID)?.title
                    )
                }
            }
        }
        .navigationTitle("Edit Insights")
    }

    func linkToEditor(insight: DTOv2.Insight) -> some View {
        NavigationLink(insight.title, destination: {
            EditorView(viewModel: EditorViewModel(insight: insight, appID: appID, insightService: insightService, groupService: groupService, lexiconService: lexiconService), selectedInsightID: $selectedInsightID)

        })
    }
}

struct EditorModeView_Previews: PreviewProvider {
    static var previews: some View {
        EditorModeView(appID: UUID.empty)
    }
}
