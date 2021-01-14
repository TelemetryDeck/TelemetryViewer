//
//  AppRootSidebar.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.01.21.
//

import SwiftUI

struct AppRootSidebar: View {
    @Binding var selectedInsightID: UUID?
    @Binding var selectedInsightGroupID: UUID
    @Binding var sidebarSection: AppRootSidebarSection
    @EnvironmentObject var api: APIRepresentative

    var appID: UUID

    var body: some View {

        VStack {
            Divider()

            Picker(selection: $sidebarSection, label: Text("")) {
                Image(systemName: "app.fill").tag(AppRootSidebarSection.InsightEditor)
                Image(systemName: "square.grid.2x2.fill").tag(AppRootSidebarSection.InsightGroupEditor)
                Image(systemName: "app").tag(AppRootSidebarSection.AppEditor)
                Image(systemName: "book").tag(AppRootSidebarSection.Lexicon)
                Image(systemName: "waveform").tag(AppRootSidebarSection.RawSignals)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            Divider()

            switch sidebarSection {
            case .InsightEditor:
                if let selectedInsightID = selectedInsightID {
                    InsightEditor(viewModel: InsightEditorViewModel(api: api, appID: appID, selectedInsightGroupID: selectedInsightGroupID, selectedInsightID: selectedInsightID), selectedInsightID: selectedInsightID)
                }
            case .InsightGroupEditor:
                InsightGroupEditor(viewModel: InsightGroupEditorViewModel(api: api, appID: appID, selectedInsightGroupID: $selectedInsightGroupID, selectedInsightID: $selectedInsightID, sidebarSection: $sidebarSection))
            case .AppEditor:
                AppEditor(appID: appID, selectedInsightGroupID: $selectedInsightGroupID, sidebarSection: $sidebarSection)
            case .Lexicon:
                LexiconView(appID: appID)
            case .RawSignals:
                SignalList(appID: appID)
            }

            Spacer()
        }
    }
}


