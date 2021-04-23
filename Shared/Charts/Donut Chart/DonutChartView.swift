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
            DonutChartContainer(chartDataSet: chartDataSet)
                .padding(.bottom)
                .padding(.horizontal)
        } else {
            Text("No Data")
        }
    }
}

struct DonutChartContainer: View {
    @State private var selectedSegmentIndex: Int?
    let chartDataSet: ChartDataSet
    
    let maxEntries: Int = 5
    
    var body: some View {
        HStack {
            DonutLegend(selectedSegmentIndex: $selectedSegmentIndex, chartDataSet: chartDataSet, maxEntries: maxEntries)
            DonutChart(selectedSegmentIndex: $selectedSegmentIndex, chartDataSet: chartDataSet, maxEntries: maxEntries)
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
        
        DonutChartContainer(chartDataSet: data)
            .padding()
            .previewLayout(.fixed(width: 285, height: 165))
    }
}
