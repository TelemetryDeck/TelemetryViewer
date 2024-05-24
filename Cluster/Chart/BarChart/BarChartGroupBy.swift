//
//  BarChartGroupBy.swift
//  Telemetry Viewer (iOS)
//
//  Created by Lukas on 23.05.24.
//

import SwiftUI
import Charts
import DataTransferObjects

struct BarChartGroupBy: View {
    let result: GroupByQueryResult

    var body: some View {
        Chart {
            /*ForEach(result.rows) { row in
                BarMark(
                    x: .value("Date", 5),
                    y: .value("Total Count", 5)
                )
            }*/
        }
    }
}
