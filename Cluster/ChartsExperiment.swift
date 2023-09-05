//
//  ChartsExperiment.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.08.23.
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
    var body: some View {
        Grid(horizontalSpacing: 15, verticalSpacing: 15) {
            GridRow {
                ClusterInstrument(query: queries["default"]!, title: "default", type: .bar).padding()
                    .glassBackgroundEffect(in: .rect(cornerRadius: 15))
                    .rotation3DEffect(.init(angle: .degrees(-5), axis: .x), anchor: .bottom)
                    
//                    .transform3DEffect(.init(rotation: .init(angle: .degrees(5), axis: .y)))
                ClusterInstrument(query: queries["daily-users"]!, title: "Daily Users", type: .bar).padding()
                    .glassBackgroundEffect(in: .rect(cornerRadius: 15))
                    .rotation3DEffect(.init(angle: .degrees(-5), axis: .x), anchor: .bottom)
                ClusterInstrument(query: queries["monthly-signals"]!, title: "Monthly Signals", type: .bar).padding()
                    .glassBackgroundEffect(in: .rect(cornerRadius: 15))
                    .rotation3DEffect(.init(angle: .degrees(-5), axis: .x), anchor: .bottom)
//                    .transform3DEffect(.init(rotation: .init(angle: .degrees(-5), axis: .y)))
            }
            GridRow {
                ClusterInstrument(query: queries["default"]!, title: "default", type: .bar).padding()
                    .glassBackgroundEffect(in: .rect(cornerRadius: 15))
//                    .transform3DEffect(.init(rotation: .init(angle: .degrees(5), axis: .y)))
                ClusterInstrument(query: queries["daily-users"]!, title: "Daily Users", type: .bar).padding()
                    .glassBackgroundEffect(in: .rect(cornerRadius: 15))
                ClusterInstrument(query: queries["monthly-signals"]!, title: "Monthly Signals", type: .bar).padding()
                    .glassBackgroundEffect(in: .rect(cornerRadius: 15))
//                    .transform3DEffect(.init(rotation: .init(angle: .degrees(-5), axis: .y)))
            }
            GridRow {
                ClusterInstrument(query: queries["default"]!, title: "default", type: .bar).padding()
                    .glassBackgroundEffect(in: .rect(cornerRadius: 15))
                    .transform3DEffect(.init(rotation: .init(angle: .degrees(5), axis: .x)))
//                    .transform3DEffect(.init(rotation: .init(angle: .degrees(5), axis: .y)))
                ClusterInstrument(query: queries["daily-users"]!, title: "Daily Users", type: .bar).padding()
                    .glassBackgroundEffect(in: .rect(cornerRadius: 15))
                    .transform3DEffect(.init(rotation: .init(angle: .degrees(5), axis: .x)))
                ClusterInstrument(query: queries["monthly-signals"]!, title: "Monthly Signals", type: .bar).padding()
                    .glassBackgroundEffect(in: .rect(cornerRadius: 15))
                    .transform3DEffect(.init(rotation: .init(angle: .degrees(5), axis: .x)))
//                    .transform3DEffect(.init(rotation: .init(angle: .degrees(-5), axis: .y)))
            }
            
        }
        
            .onAppear() {
                TelemetryManager.send("ChartsExperimentShown", for: "cant-generate-user")
            }
    }
}
