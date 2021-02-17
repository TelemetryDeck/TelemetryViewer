//
//  AppRootView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 17.02.21.
//

import SwiftUI

struct AppRootView: View {
    @EnvironmentObject var api: APIRepresentative
    let app: TelemetryApp

    @State var selection: AppRootViewSelection = .rawSignals

    private var insightGroup: InsightGroup? {
        switch selection {
        case .insightGroup(let group):
            return group
        default:
            return nil
        }
    }

    var body: some View {
        TabView(selection: $selection) {
            ForEach(api.insightGroups[app] ?? []) { insightGroup in
                InsightGroupView(app: app, insightGroup: insightGroup)
                    .tabItem { Label(insightGroup.title, systemImage: "square.grid.2x2") }
                    .tag(AppRootViewSelection.insightGroup(group: insightGroup))
            }

            LexiconView(appID: app.id)
                .tabItem { Label("Lexicon", systemImage: "book") }
                .tag(AppRootViewSelection.lexicon)

            SignalList(appID: app.id)
                .tabItem { Label("Raw Signals", systemImage: "waveform") }
                .tag(AppRootViewSelection.rawSignals)
        }
        .navigationTitle(app.name)
        .onAppear {
            if let firstInsightGroup = api.insightGroups[app]?.first {
                selection = .insightGroup(group: firstInsightGroup)
            }
        }
        .toolbar {
            ToolbarItem {
                Menu("Manu") {
                    Section {
                        NavigationLink("Edit App", destination: Text("Editor APp"))

                        if let insightGroup = insightGroup {
                            NavigationLink("Edit Group", destination: Text("Editor Group"))

                            Button(action: {
                                let definitionRequestBody = InsightDefinitionRequestBody.new(groupID: insightGroup.id)
                                api.create(insightWith: definitionRequestBody, in: insightGroup, for: app) { _ in api.getInsightGroups(for: app) }
                            }) {
                                Label("New Insight", systemImage: "plus.rectangle")
                            }
                        }
                    }
                }
            }
        }
    }
}
