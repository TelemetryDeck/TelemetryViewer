//
//  ChartsExperiment.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.08.23.
//

import Charts
import DataTransferObjects
import SwiftUI


let queries: [String: CustomQuery] = [
    "default": CustomQuery(
        queryType: .timeseries,
        dataSource: "telemetry-signals",
        relativeIntervals: [.init(beginningDate: .init(.beginning, of: .day, adding: -30), endDate: .init(.end, of: .day, adding: 0))],
        granularity: .day,
        aggregations: [.thetaSketch(.init(type: .thetaSketch, name: "count", fieldName: "clientUser"))]
    ),
    "daily-users": CustomQuery(
        queryType: .timeseries,
        dataSource: "telemetry-signals",
        relativeIntervals: [.init(beginningDate: .init(.beginning, of: .day, adding: -30), endDate: .init(.end, of: .day, adding: 0))],
        granularity: .day,
        aggregations: [.longSum(.init(type: .longSum, name: "count", fieldName: "count"))]
    ),
    "monthly-signals": CustomQuery(
        queryType: .timeseries,
        dataSource: "telemetry-signals",
        relativeIntervals: [.init(beginningDate: .init(.beginning, of: .day, adding: -30), endDate: .init(.end, of: .day, adding: 0))],
        granularity: .hour,
        aggregations: [.longSum(.init(type: .longSum, name: "count", fieldName: "count"))]
    ),
]

extension TimeSeriesQueryResultRow: Identifiable {
    public var id: Date { timestamp }
}

struct ChartsExperiment: View {
    let queryID: String?
    
    var body: some View {
        ClusterInstrument(query: queries[queryID ?? "default"]!, title: queryID ?? "default", type: .bar).padding()
    }
}
