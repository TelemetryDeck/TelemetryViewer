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
    let topNQueryResult: TopNQueryResult
    let query: CustomQuery

    var body: some View {

        Chart {
            ForEach(topNQueryResult.rows, id: \.self) { (row: TopNQueryResultRow) in

                ForEach(row.result, id: \.self) { (rowResult: AdaptableQueryResultItem) in

                    ForEach(query.aggregations ?? [], id: \.self) { (aggregator: Aggregator) in
                        if let metricValue = getMetricValue(rowResult: rowResult){
                            getBarMark(
                                timeStamp: row.timestamp,
                                name: getAggregatorName(aggregator: aggregator),
                                metricValue: metricValue,
                                metricName: getMetricName(rowResult: rowResult)
                            )
                        }
                    }

                }

            }
        }
        .chartForegroundStyleScale(range: Color.chartColors)

    }

    // swiftlint:disable cyclomatic_complexity
    func granularity() -> Calendar.Component{
        switch query.granularity {
        case .all:
                .month
        case .none:
                .month
        case .second:
                .hour
        case .minute:
                .hour
        case .fifteen_minute:
                .hour
        case .thirty_minute:
                .hour
        case .hour:
                .hour
        case .day:
                .day
        case .week:
                .weekOfYear
        case .month:
                .month
        case .quarter:
                .quarter
        case .year:
                .year
        }
    }
    // swiftlint:enable cyclomatic_complexity

    func getBarMark(timeStamp: Date, name: String, metricValue: Double, metricName: String) -> some ChartContent {
        return BarMark(
            x: .value("Date", timeStamp, unit: granularity()),
            y: .value(name, metricValue)
        )
        .foregroundStyle(by: .value(getDimensionName(from: query.dimension) ?? "Not found", metricName))
    }

    func getDimensionName(from: DimensionSpec?) -> String? {
        switch from {
        case .default(let defaultDimensionSpec):
            defaultDimensionSpec.outputName
        case .extraction(let extractionDimensionSpec):
            extractionDimensionSpec.outputName
        case .none:
            nil
        }
    }

    func getMetricName(rowResult: AdaptableQueryResultItem) -> String{
        let dimensionName = getDimensionName(from: query.dimension) ?? "Not found"
        let metricName = rowResult.dimensions[dimensionName] ?? "Not found"
        return metricName
    }

    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    func getAggregatorName(aggregator: Aggregator) -> String {
        switch aggregator {
        case .count(let a):
            a.name
        case .cardinality(let a):
            a.name
        case .longSum(let a):
            a.name
        case .doubleSum(let a):
            a.name
        case .floatSum(let a):
            a.name
        case .doubleMin(let a):
            a.name
        case .doubleMax(let a):
            a.name
        case .floatMin(let a):
            a.name
        case .floatMax(let a):
            a.name
        case .longMin(let a):
            a.name
        case .longMax(let a):
            a.name
        case .doubleMean(let a):
            a.name
        case .doubleFirst(let a):
            a.name
        case .doubleLast(let a):
            a.name
        case .floatFirst(let a):
            a.name
        case .floatLast(let a):
            a.name
        case .longFirst(let a):
            a.name
        case .longLast(let a):
            a.name
        case .stringFirst(let a):
            a.name
        case .stringLast(let a):
            a.name
        case .doubleAny(let a):
            a.name
        case .floatAny(let a):
            a.name
        case .longAny(let a):
            a.name
        case .stringAny(let a):
            a.name
        case .thetaSketch(let a):
            a.name
        case .filtered(let a):
            getAggregatorName(aggregator: a.aggregator)
        }
    }
    // swiftlint:enable cyclomatic_complexity
    // swiftlint:enable function_body_length

    func getMetricValue(rowResult: AdaptableQueryResultItem) -> Double? {
        guard let metric = query.metric, let metricName = getMetricName(metric: metric) else {
            return nil
        }
        let value = rowResult.metrics[metricName]
        return value
    }

    func getMetricName(metric: TopNMetricSpec) -> String? {
        switch metric {
        case .numeric(let numericTopNMetricSpec):
            return numericTopNMetricSpec.metric
        case .inverted(let invertedTopNMetricSpec):
            return getMetricName(metric: invertedTopNMetricSpec.metric)
        default:
            return nil
        }
    }

}
