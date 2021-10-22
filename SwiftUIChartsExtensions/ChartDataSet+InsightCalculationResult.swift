//
//  ChartDataSet+InsightCalculationResult.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 22.10.21.
//

import DataTransferObjects
import Foundation
import SwiftUICharts

public extension ChartDataSet {
    init(data: [DTOv2.InsightCalculationResultRow], groupBy: DataTransferObjects.InsightGroupByInterval? = nil) {
        if let groupBy = groupBy {
            let groupBy: SwiftUICharts.InsightGroupByInterval? = SwiftUICharts.InsightGroupByInterval(rawValue: groupBy.rawValue)

            self.init(
                data: data.map { ChartDataPoint(insightCalculationResultRow: $0) },
                groupBy: groupBy
            )
        } else {
            self.init(
                data: data.map { ChartDataPoint(insightCalculationResultRow: $0) },
                groupBy: nil
            )
        }
    }

    init(data: [DTOv1.InsightData], groupBy: DataTransferObjects.InsightGroupByInterval? = nil) {
        if let groupBy = groupBy {
            let groupBy: SwiftUICharts.InsightGroupByInterval? = SwiftUICharts.InsightGroupByInterval(rawValue: groupBy.rawValue)
            self.init(
                data: data.map { ChartDataPoint(insightData: $0) },
                groupBy: groupBy
            )
        } else {
            self.init(
                data: data.map { ChartDataPoint(insightData: $0) },
                groupBy: nil
            )
        }
    }
}
