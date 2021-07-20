//
//  ServiceBarChartView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 20.07.21.
//

import SwiftUI

struct BarChartView: View {
    @EnvironmentObject var insightCalculationService: InsightCalculationService

    let insightID: UUID
    let insightGroupID: UUID
    let appID: UUID

    @Binding var topSelectedInsightID: UUID?
    private var isSelected: Bool {
        topSelectedInsightID == insightID
    }

    var body: some View {
        if let insightData = insightCalculationService.calculationResult(for: insightID, in: insightGroupID, in: appID) {
            BarChartContentView(insightCalculationResult: insightData.insightData, chartDataSet: insightData.chartDataSet, isSelected: isSelected)
        } else {
            Text("Cannot display this as a Chart")
        }
    }
}
