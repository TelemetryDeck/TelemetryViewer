//
//  ServiceBarChartView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 20.07.21.
//

import SwiftUI
import DataTransferObjects
import SwiftUICharts

struct BarChartView: View {
    let chartDataSet: ChartDataSet
    let isSelected: Bool

    var body: some View {
        BarChartContentView(chartDataSet: chartDataSet, isSelected: isSelected)
    }
}

struct ServiceBarChartView: View {
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
            BarChartContentView(chartDataSet: insightData.chartDataSet, isSelected: isSelected)
        } else {
            Text("Cannot display this as a Chart")
        }
    }
}
