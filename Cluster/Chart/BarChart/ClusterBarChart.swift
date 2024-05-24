//
//  ClusterBarChart.swift
//  Telemetry Viewer (iOS)
//
//  Created by Lukas on 23.05.24.
//
import SwiftUI
import DataTransferObjects

struct ClusterBarChart: View {
    let query: CustomQuery
    let result: QueryResult

    var body: some View {
        switch query.queryType {
        case .timeseries:
            if case let .timeSeries(result) = result {
                BarChartTimeSeries(result: result)
            } else {
                Text("Mismatch in query type and result type 1")
            }
        /*case .groupBy:
            if case let .groupBy(result) = result {
                BarChartGroupBy(result: result)
            } else {
                Text("Mismatch in query type and result type 2")
            }*/
        case .topN:
            if case let .topN(result) = result {
                BarChartTopN(result: result)
            } else {
                Text("Mismatch in query type and result type 2")
            }
        default:
            Text("\(query.queryType.rawValue) bar charts are not supported.")
        }
    }
}
