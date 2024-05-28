//
//  ClusterChart.swift
//  Telemetry Viewer (iOS)
//
//  Created by Lukas on 23.05.24.
//

import SwiftUI
import DataTransferObjects

/// Cluster/Chart – given a query and a result, displays the result
struct ClusterChart: View {

    let query: CustomQuery
    let result: QueryResult
    let type: InsightDisplayMode

    var body: some View {
        switch type {
        case .barChart:
            ClusterBarChart(query: query, result: result)
        case .lineChart:
            ClusterLineChart(query: query, result: result)
        case .pieChart:
            ClusterPieChart(query: query, result: result)
        default:
            Text("Not supported")
        }
    }
}
