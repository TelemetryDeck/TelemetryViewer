//
//  Extensions.swift
//  Telemetry Viewer (iOS)
//
//  Created by Lukas on 28.05.24.
//

import Foundation
import DataTransferObjects

extension CustomQuery {
    var granularityAsCalendarComponent: Calendar.Component{
        switch self.granularity {
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
}

extension Aggregator {
    var name: String {
        switch self {
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
            a.aggregator.name
        }
    }
}

extension DimensionSpec {
    var name: String? {
        switch self {
        case .default(let defaultDimensionSpec):
            defaultDimensionSpec.outputName
        case .extraction(let extractionDimensionSpec):
            extractionDimensionSpec.outputName
        }
    }
}

extension TopNMetricSpec {
    var name: String? {
        switch self {
        case .numeric(let numericTopNMetricSpec):
            return numericTopNMetricSpec.metric
        case .inverted(let invertedTopNMetricSpec):
            return invertedTopNMetricSpec.metric.name
        default:
            return nil
        }
    }
}
