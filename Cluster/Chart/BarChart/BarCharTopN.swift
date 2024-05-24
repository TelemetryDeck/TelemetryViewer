//
//  BarCharTopN.swift
//  Telemetry Viewer (iOS)
//
//  Created by Lukas on 23.05.24.
//

import SwiftUI
import Charts
import DataTransferObjects

struct BarChartTopN: View {
    //let query: CustomQuery
    let result: TopNQueryResult

    var body: some View {
        Chart {
            //ForEach(result.rows) { row in
            //    BarMark(
            //        x: .value("Date", 4),
            //        y: .value("Total Count", 5)
            //    )
            //}
        }
    }
}
