//
//  ChartDataPoint+InsightCalculationResult.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 22.10.21.
//

import DataTransferObjects
import Foundation
import SwiftUICharts

extension ChartDataPoint {
    init(insightCalculationResultRow: DTOv2.InsightCalculationResultRow) {
        self.init(xAxisValue: insightCalculationResultRow.xAxisValue, yAxisValue: insightCalculationResultRow.yAxisValue)
    }

    init(insightData: DTOv1.InsightData) {
        if let stringValue = insightData.yAxisValue {
            self.init(xAxisValue: insightData.xAxisValue, yAxisValue: Int64(stringValue))
        } else {
            self.init(xAxisValue: insightData.xAxisValue, yAxisValue: nil)
        }
    }
}
