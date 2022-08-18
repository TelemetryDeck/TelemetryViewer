//
//  InsightDisplayMode+Extensions.swift
//  Telemetry Viewer (iOS)
//
//  Created by Martin Václavík on 29.12.2021.
//

import SwiftUI
import DataTransferObjects

extension InsightDisplayMode {
    var chartTypeExplanationText: String {
        switch self {
        case .number:
            return "Currently, 'Number' is the selected Chart Type. This chart type is no longer supported, and you should choose the 'Raw' instead."
        case .raw:
            return "Displays the insight's data directly as numbers."
        case .barChart:
            return "Displays a bar chart for the insight's data."
        case .lineChart:
            return "Displays a line chart for the insight's data."
        case .pieChart:
            return "Displays a pie chart for the insight's data. This is especially helpful in combination with the 'breakdown' function."
        }
    }

    var chartImage: Image {
        switch self {
        case .raw:
            return Image(systemName: "list.dash.header.rectangle")
        case .barChart:
            return Image(systemName: "chart.bar.fill")
        case .lineChart:
            return Image(systemName: "chart.xyaxis.line")
        case .pieChart:
            return Image(systemName: "chart.pie.fill")
        default:
            return Image(systemName: "number.square")
        }
    }
}
