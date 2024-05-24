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
    //let query: CustomQuery
    let result: TimeSeriesQueryResult

    var body: some View {
        Chart {
            ForEach(result.rows, id: \.timestamp) { row in
                LineMark(
                    x: .value("Date", row.timestamp),
                    y: .value("Total Count", row.result["count"]?.value ?? 0)
                )
            }
            .interpolationMethod(.cardinal)


            ForEach(result.rows, id: \.timestamp) { row in
                AreaMark(x: .value("Date", row.timestamp),
                         y: .value("Total Count", row.result["count"]?.value ?? 0))
            }
            .interpolationMethod(.cardinal)
            .foregroundStyle(LinearGradient(colors: [Color.telemetryOrange.opacity(0.25), Color.telemetryOrange.opacity(0.0)], startPoint: .top, endPoint: .bottom))
        }
    }
}
