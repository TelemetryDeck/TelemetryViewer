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
                BarChartTimeSeries(result: result, query: query)
            }
        case .topN:
            if case let .topN(result) = result {
                BarChartTopN(topNQueryResult: result, query: query)
            }
        default:
            Text("\(query.queryType.rawValue) bar charts are not supported.")
        }
    }
}
