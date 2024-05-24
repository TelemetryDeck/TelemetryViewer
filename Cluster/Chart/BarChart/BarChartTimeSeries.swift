//
//  BarChartTimeSeries.swift
//  Telemetry Viewer (iOS)
//
//  Created by Lukas on 23.05.24.
//

import SwiftUI
import Charts
import DataTransferObjects

struct BarChartTimeSeries: View {
    //let query: CustomQuery
    let result: TimeSeriesQueryResult

    var body: some View {
        Chart {
            ForEach(result.rows, id: \.timestamp) { row in
                BarMark(
                    x: .value("Date", row.timestamp),
                    y: .value("Total Count", row.result["count"]?.value ?? 0)
                )
            }
        }
    }
}
