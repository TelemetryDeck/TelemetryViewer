//
//  EditInsightView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 17.02.21.
//

import SwiftUI

enum InsightSidebarSection {
    case InsightEditor
    case InsightGroupEditor
    case AppEditor
}

struct InsightSidebarView: View {
    @EnvironmentObject var api: APIRepresentative

    let app: TelemetryApp
    let insightGroup: InsightGroup?
    let insight: Insight?

    @State var sidebarSection: InsightSidebarSection = .InsightEditor

    var body: some View {
        Group {
            switch sidebarSection {
            case .InsightEditor:
                NewInsightEditor(app: app, insightGroup: insightGroup!, insight: insight!)
            case .InsightGroupEditor:
                Text("InsightGroupEditor")
            case .AppEditor:
                Text("App Editor")
            }
        }
        .toolbar {
            Spacer()
            Picker(selection: $sidebarSection, label: Text("")) {
                Image(systemName: "app").tag(InsightSidebarSection.AppEditor)

                if insightGroup != nil {
                    Image(systemName: "square.grid.2x2.fill").tag(InsightSidebarSection.InsightGroupEditor)
                }

                if insight != nil {
                    Image(systemName: "app.fill").tag(InsightSidebarSection.InsightEditor)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}
