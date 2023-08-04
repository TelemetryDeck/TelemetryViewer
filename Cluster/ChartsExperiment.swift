//
//  ChartsExperiment.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.08.23.
//

import Charts
import DataTransferObjects
import SwiftUI

let exampleQuery = CustomQuery(
    queryType: .timeseries,
    dataSource: "telemetry-signals",
    relativeIntervals: [.init(beginningDate: .init(.beginning, of: .day, adding: -30), endDate: .init(.end, of: .day, adding: 0))],
    granularity: .day,
    aggregations: [.thetaSketch(.init(type: .thetaSketch, name: "count", fieldName: "clientUser"))]
)

extension TimeSeriesQueryResultRow: Identifiable {
    public var id: Date { timestamp }
}

struct ChartsExperiment: View {
    var body: some View {
        ClusterInstrument(query: exampleQuery, title: "Example Query", type: .bar)
    }
}

#Preview {
    ChartsExperiment()
}
