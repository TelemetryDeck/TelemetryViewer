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

    @State var selection: AppRootViewSelection = .noSelection

    private var insightGroup: InsightGroup? {
        switch selection {
        case .insightGroup(let group):
            return group
        default:
            return nil
        }
    }

    var body: some View {
        Group {
            switch selection {
            case .lexicon:
                LexiconView(appID: app.id)
            case .rawSignals:
                SignalList(appID: app.id)
            case .insightGroup(let group):
                InsightGroupView(app: app, insightGroup: group)
            case .noSelection:
                Text("Hi!")
            }
        }
        .navigationTitle(app.name)
        .onAppear {
            if let firstInsightGroup = api.insightGroups[app]?.first, selection == .noSelection {
                selection = .insightGroup(group: firstInsightGroup)
            }
        }
        .toolbar {
            Spacer()
            
            Picker("View Mode", selection: $selection) {
                ForEach(api.insightGroups[app] ?? []) { insightGroup in
                    Text(insightGroup.title).tag(AppRootViewSelection.insightGroup(group: insightGroup))
                }

                Image(systemName: "book")
                    .tag(AppRootViewSelection.lexicon)
                Image(systemName: "waveform")
                    .tag(AppRootViewSelection.rawSignals)
            }.pickerStyle(SegmentedPickerStyle())

            Spacer()

            if let insightGroup = insightGroup {
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
