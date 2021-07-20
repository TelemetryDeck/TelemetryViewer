//
//  ServiceDonutChartView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 20.07.21.
//

import SwiftUI

struct DonutChartView: View {
    @EnvironmentObject var insightCalculationService: InsightCalculationService
    
    let insightID: UUID
    let insightGroupID: UUID
    let appID: UUID

    @Binding var topSelectedInsightID: UUID?
    private var isSelected: Bool {
        topSelectedInsightID == insightID
    }
    
    var body: some View {
        if let insightData = insightCalculationService.insightData(for: insightID, in: insightGroupID, in: appID) {
            DonutChartContainer(chartDataset: insightData.chartDataSet, isSelected: isSelected)
                .padding(.bottom)
                .padding(.horizontal)
        } else {
            Text("No Data")
        }
    }
}
