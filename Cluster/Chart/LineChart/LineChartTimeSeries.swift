//
//  LineChartTimeSeries.swift
//  Telemetry Viewer (iOS)
//
//  Created by Lukas on 23.05.24.
//

import SwiftUI
import Charts
import DataTransferObjects

struct LineChartTimeSeries: View {
    let query: CustomQuery
    let result: TimeSeriesQueryResult

    var body: some View {
        Chart {
            ForEach(result.rows) { row in
                LineMark(
                    x: .value("Date", row.timestamp),
                    y: .value("Total Count", row.result["count"]?.value ?? 0)
                )
            }
        }
    }
}
