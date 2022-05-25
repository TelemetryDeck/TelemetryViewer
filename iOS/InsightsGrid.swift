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
    @Binding var selectedInsightID: DTOv2.Insight.ID?
    @Binding var sidebarVisible: Bool

    let insightGroup: DTOv2.Group
    let isSelectable: Bool

    var body: some View {
        let allInsights = insightGroup.insightIDs.map {
            ($0, insightService.insight(withID: $0))
        }

        let loadedInsights = allInsights.filter { $0.1 != nil }
        let loadingInsights = allInsights.filter { $0.1 == nil }
        let expandedInsights = loadedInsights.filter { $0.1?.isExpanded == true }.sorted { $0.1?.order ?? 0 < $1.1?.order ?? 0 }
        let unexpandedInsights = loadedInsights.filter { $0.1?.isExpanded == false }.sorted { $0.1?.order ?? 0 < $1.1?.order ?? 0 }

        return LazyVGrid(columns: [GridItem(.adaptive(minimum: 800), spacing: spacing)], alignment: .leading, spacing: spacing) {
            ForEach(expandedInsights.map { $0.0 }, id: \.self) { insightID in
                InsightCard(selectedInsightID: $selectedInsightID, sidebarVisible: $sidebarVisible, insightID: insightID, isSelectable: isSelectable)
                    .id(insightID)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: spacing)], alignment: .leading, spacing: spacing) {
                ForEach(unexpandedInsights.map { $0.0 }, id: \.self) { insightID in
                    InsightCard(selectedInsightID: $selectedInsightID, sidebarVisible: $sidebarVisible, insightID: insightID, isSelectable: isSelectable)
                        .id(insightID)
                }
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: spacing)], alignment: .leading, spacing: spacing) {
                ForEach(loadingInsights.map { $0.0 }, id: \.self) { insightID in
                    InsightCard(selectedInsightID: $selectedInsightID, sidebarVisible: $sidebarVisible, insightID: insightID, isSelectable: isSelectable)
                        .id(insightID)
                }
            }
        }
        .refreshable {
            for insightID in insightGroup.insightIDs {
                insightService.retrieveInsight(with: insightID)
            }
        }
    }
}
