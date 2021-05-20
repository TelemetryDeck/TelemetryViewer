//
//  DonutChartView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 07.10.20.
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
        if let insightData = insightCalculationService.insightData(for: insightID, in: insightGroupID, in: appID), let chartDataSet = try? ChartDataSet(data: insightData.data) {
            DonutChartContainer(chartDataset: chartDataSet, isSelected: isSelected)
                .padding(.bottom)
                .padding(.horizontal)
        } else {
            Text("No Data")
        }
    }
}

struct DonutChartContainer: View {
    let chartDataset: ChartDataSet
    let maxEntries: Int = 4
    let isSelected: Bool
    
    private var chartDataPoints: [ChartDataPoint] {
        var chartDataPoints: [ChartDataPoint] = Array(chartDataset.data.prefix(maxEntries))
        
        if chartDataset.data.count > maxEntries {
            let missingEntriesCount = chartDataset.data.count - maxEntries
            let missingEntries = Array(chartDataset.data.suffix(missingEntriesCount))
            let otherSum = missingEntries.map { $0.yAxisValue }.reduce(Double(0), +)
            
            chartDataPoints.append(ChartDataPoint(xAxisValue: "Other", yAxisValue: otherSum))
        }
                
        return chartDataPoints
    }
    
    var body: some View {
        HStack {
            DonutLegend(chartDataPoints: chartDataPoints, isSelected: isSelected)
            DonutChart(chartDataPoints: chartDataPoints)
                .transition(.opacity)
        }
    }
}


// MARK: - Preview
struct DonutChartView_Previews: PreviewProvider {
    static var data: ChartDataSet = try! ChartDataSet(
        data: [
            DTO.InsightData(xAxisValue: "Cool Users", yAxisValue: "859"),
            DTO.InsightData(xAxisValue: "Enthusiastic Users", yAxisValue: "515"),
            DTO.InsightData(xAxisValue: "Happy Users", yAxisValue: "321"),
            DTO.InsightData(xAxisValue: "Interested Users", yAxisValue: "214"),
            DTO.InsightData(xAxisValue: "Encouraged Users", yAxisValue: "145"),
            DTO.InsightData(xAxisValue: "Disinterested Users", yAxisValue: "13"),
            DTO.InsightData(xAxisValue: "Unhappy Users", yAxisValue: "4"),
            DTO.InsightData(xAxisValue: "Angry Users", yAxisValue: "2")
        ])

    static var previews: some View {

        DonutChartContainer(chartDataset: data, isSelected: false)
            .padding()
            .previewLayout(.fixed(width: 285, height: 165))
    }
}
