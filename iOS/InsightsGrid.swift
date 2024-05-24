//
//  InsightsGrid.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 24.09.21.
//

import DataTransferObjects
import SwiftUI

struct InsightsGrid: View {
    @EnvironmentObject var insightService: InsightService
    @Binding var selectedInsightID: InsightInfo.ID?
    @Binding var sidebarVisible: Bool

    let insightGroup: InsightGroupInfo
    let isSelectable: Bool

    var body: some View {

        VStack{
            ForEach(insightGroup.insights, id: \.id) { insight in
                if let query = insight.query {
                    ClusterInstrument(query: query, title: insight.title, type: insight.displayMode)
                } else {
                    Text("Couldn't get query")
                }
            }
        }
    }
}
