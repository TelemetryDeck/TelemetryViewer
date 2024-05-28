//
//  PieChartGroupBy.swift
//  Telemetry Viewer (iOS)
//
//  Created by Lukas on 28.05.24.
//

import SwiftUI
import Charts
import DataTransferObjects

struct PieChartTopN: View {
    let topNQueryResult: TopNQueryResult
    let query: CustomQuery

    var body: some View {

        Chart {
            ForEach(topNQueryResult.rows, id: \.self) { (row: TopNQueryResultRow) in

                ForEach(row.result, id: \.self) { (rowResult: AdaptableQueryResultItem) in

                    ForEach(query.aggregations ?? [], id: \.self) { (aggregator: Aggregator) in
                        if let metricValue = getMetricValue(rowResult: rowResult){
                            if query.granularity != .all {
                                getBarMark(
                                    timeStamp: row.timestamp,
                                    name: aggregator.name,
                                    metricValue: metricValue,
                                    metricName: getMetricName(rowResult: rowResult)
                                )
                            } else {
                                getSectorMark(
                                    name: aggregator.name,
                                    metricValue: metricValue,
                                    metricName: getMetricName(rowResult: rowResult)
                                )
                            }
                        }
                    }

                }

            }
        }
        .chartForegroundStyleScale(range: Color.chartColors)

    }

    func getSectorMark(name: String, metricValue: Double, metricName: String) -> some ChartContent {
        return SectorMark(
            angle: .value(name, metricValue),
            innerRadius: .ratio(0.5),
            angularInset: 1.0
        )
        .cornerRadius(2)
        .foregroundStyle(by: .value(query.dimension?.name ?? "No value", metricName))
    }

    func getBarMark(timeStamp: Date, name: String, metricValue: Double, metricName: String) -> some ChartContent {
        return BarMark(
            x: .value("Date", timeStamp, unit: query.granularityAsCalendarComponent),
            y: .value(name, metricValue),
            stacking: .normalized
        )
        .foregroundStyle(by: .value(query.dimension?.name ?? "No value", metricName))
        .cornerRadius(2)
    }

    func getMetricName(rowResult: AdaptableQueryResultItem) -> String{
        let dimensionName = query.dimension?.name ?? "No value"
        let metricName = rowResult.dimensions[dimensionName] ?? "Not found"
        return metricName
    }

    func getMetricValue(rowResult: AdaptableQueryResultItem) -> Double? {
        guard let metricName = query.metric?.name else {
            return nil
        }
        let value = rowResult.metrics[metricName]
        return value
    }

}
