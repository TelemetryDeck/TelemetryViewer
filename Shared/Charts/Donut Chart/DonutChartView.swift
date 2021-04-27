//
//  DonutChartView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 07.10.20.
//

import SwiftUI
import TelemetryModels

struct DonutChartView: View {
    var insightDataID: UUID
    @EnvironmentObject var api: APIRepresentative
    
    @Binding var topSelectedInsightID: UUID?
    private var isSelected: Bool {
        topSelectedInsightID == insightDataID
    }
    
    private var insightData: InsightDTO? { api.insightData[insightDataID] }
    private var chartDataSet: ChartDataSet? {
        guard let insightData = insightData else { return nil }
        return try? ChartDataSet(data: insightData.data)
    }
    
    var body: some View {
        if let chartDataSet = chartDataSet {
            DonutChartContainer(chartDataset: chartDataSet)
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
            DonutLegend(chartDataPoints: chartDataPoints)
            DonutChart(chartDataPoints: chartDataPoints)
                .transition(.opacity)
        }
    }
}


// MARK: - Preview
struct DonutChartView_Previews: PreviewProvider {
    static var data: ChartDataSet = try! ChartDataSet(
        data: [
            InsightData(xAxisValue: "Cool Users", yAxisValue: "859"),
            InsightData(xAxisValue: "Enthusiastic Users", yAxisValue: "515"),
            InsightData(xAxisValue: "Happy Users", yAxisValue: "321"),
            InsightData(xAxisValue: "Interested Users", yAxisValue: "214"),
            InsightData(xAxisValue: "Encouraged Users", yAxisValue: "145"),
            InsightData(xAxisValue: "Disinterested Users", yAxisValue: "13"),
            InsightData(xAxisValue: "Unhappy Users", yAxisValue: "4"),
            InsightData(xAxisValue: "Angry Users", yAxisValue: "2")
        ])
    
    static var previews: some View {
        
        DonutChartContainer(chartDataset: data)
            .padding()
            .previewLayout(.fixed(width: 285, height: 165))
    }
}
