//
//  BarChartTimeSeries.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.08.23.
//

import SwiftUI
import Charts
import DataTransferObjects


struct BarChartTimeSeries: View {
    let query: CustomQuery
    let result: TimeSeriesQueryResult
    
    var body: some View {
        Chart {
            ForEach(result.rows) { row in
                BarMark(
                    x: .value("Date", row.timestamp),
                    y: .value("Total Count", row.result["count"]?.value ?? 0)
                )
            }
        }
    }
}
