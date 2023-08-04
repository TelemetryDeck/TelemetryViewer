//
//  Chart.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.08.23.
//

import SwiftUI
import DataTransferObjects

/// Cluster/Chart – given a query and a result, displays the result
struct ClusterChart: View {
    enum ChartType {
        case bar
    }
    
    let query: CustomQuery
    let result: QueryResult
    let type: ChartType
    
    var body: some View {
        switch type {
        case .bar:
            ClusterBarChart(query: query, result: result)
        }
    }
}
