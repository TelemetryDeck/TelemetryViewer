//
//  ClusterExperiment.swift
//  Telemetry Viewer (iOS)
//
//  Created by Lukas on 23.05.24.
//

import Charts
import DataTransferObjects
import SwiftUI
import TelemetryClient


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
    //@EnvironmentObject var api: APIClient

    var body: some View {
        VStack {
                ClusterInstrument(query: queries["default"]!, title: "default", type: .bar)
                 //   .glassBackgroundEffect(in: .rect(cornerRadius: 15))
                 //   .rotation3DEffect(.init(angle: .degrees(-5), axis: .x), anchor: .bottom)

//                    .transform3DEffect(.init(rotation: .init(angle: .degrees(5), axis: .y)))
                ClusterInstrument(query: queries["daily-users"]!, title: "Daily Users", type: .line)
                 //   .glassBackgroundEffect(in: .rect(cornerRadius: 15))
                 //   .rotation3DEffect(.init(angle: .degrees(-5), axis: .x), anchor: .bottom)
                ClusterInstrument(query: queries["monthly-signals"]!, title: "Monthly Signals", type: .bar)
                 //  .glassBackgroundEffect(in: .rect(cornerRadius: 15))
                 //  .rotation3DEffect(.init(angle: .degrees(-5), axis: .x), anchor: .bottom)
//                   .transform3DEffect(.init(rotation: .init(angle: .degrees(-5), axis: .y)))
            }
        .onAppear() {
            TelemetryManager.send("ChartsExperimentShown", for: "cant-generate-user")
        }
    }
}
