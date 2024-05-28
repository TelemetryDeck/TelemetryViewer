//
//  PieChartGroupBy.swift
//  Telemetry Viewer (iOS)
//
//  Created by Lukas on 28.05.24.
//

import SwiftUI
import Charts
import DataTransferObjects

struct PieChartGroupBy: View {
    let result: GroupByQueryResult
    let query: CustomQuery

    var body: some View {
        Chart {
            ForEach(result.rows, id: \.self) { row in

            }
        }
        .chartForegroundStyleScale(range: Color.chartColors)
    }
}
