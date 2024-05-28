//
//  ClusterPieChart.swift
//  Telemetry Viewer (iOS)
//
//  Created by Lukas on 28.05.24.
//

import SwiftUI
import DataTransferObjects

struct ClusterPieChart: View {
    let query: CustomQuery
    let result: QueryResult

    var body: some View {
        switch query.queryType {
        case .groupBy:
            if case let .groupBy(result) = result {
                PieChartGroupBy(result: result, query: query)
            }
        default:
            Text("\(query.queryType.rawValue) bar charts are not supported.")
        }
    }
}
