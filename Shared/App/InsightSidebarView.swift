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
                if let insightGroup = insightGroup, let insight = insight {
                    NewInsightEditor(app: app, insightGroup: insightGroup, insight: insight)
                } else {
                    Text("Please select an Insight")
                }
            case .InsightGroupEditor:
                if let insightGroup = insightGroup {
                    NewInsightGroupEditor(app: app, insightGroup: insightGroup)
                } else {
                    Text("Please select an Insight Group")
                }
            }
        }
        .onAppear {
            if insight == nil {
                sidebarSection = .InsightGroupEditor
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Picker(selection: $sidebarSection, label: Text("")) {
                    if insightGroup != nil {
                        Image(systemName: "square.grid.2x2.fill").tag(InsightSidebarSection.InsightGroupEditor)
                    }

                    if insight != nil {
                        Image(systemName: "app.fill").tag(InsightSidebarSection.InsightEditor)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            ToolbarItemGroup {
                Spacer()

                Button(action: toggleRightSidebar) {
                    Image(systemName: "sidebar.right")
                        .help("Toggle Sidebar")
                }
                .help("Toggle the right sidebar")
            }
        }
    }
}
