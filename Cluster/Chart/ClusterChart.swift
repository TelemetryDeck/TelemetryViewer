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
    enum ChartType {
        case bar
        case line
    }

    let query: CustomQuery
    let result: QueryResult
    let type: ChartType

    var body: some View {
        switch type {
        case .bar:
            VStack{
                ClusterBarChart(query: query, result: result)
            }
        case .line:
            VStack {
                ClusterLineChart(query: query, result: result)
            }
        }
    }
}
