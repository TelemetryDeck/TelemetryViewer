//
//  DonutChartView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 07.10.20.
//

import SwiftUI
import WidgetKit

public struct DonutChartView: View {
    public init(chartDataset: ChartDataSet, isSelected: Bool) {
        self.chartDataset = chartDataset
        self.isSelected = isSelected
    }

    #warning("TODO: Should be chartDataSet, not chartDataset")
    let chartDataset: ChartDataSet
    let maxEntries: Int = 4
    let isSelected: Bool

    @State var hoveringDataPoint: ChartDataPoint?
    @Environment(\.widgetFamily) var family: WidgetFamily

    private var chartDataPoints: [ChartDataPoint] {
        var chartDataPoints: [ChartDataPoint] = Array(chartDataset.data.prefix(maxEntries))

        if chartDataset.data.count > maxEntries {
            let missingEntriesCount = chartDataset.data.count - maxEntries
            let missingEntries = Array(chartDataset.data.suffix(missingEntriesCount))
            let otherSum = missingEntries.map { Double($0.yAxisValue ?? 0) }.reduce(Double(0), +)

            chartDataPoints.append(ChartDataPoint(xAxisValue: "Other", yAxisValue: Int64(otherSum)))
        }

        return chartDataPoints
    }

    public var body: some View {
        GeometryReader { geometry in
            if geometry.size.height < 300 {
                HStack {
                    if family != .systemSmall {
                        DonutLegend(chartDataPoints: chartDataPoints, isSelected: isSelected, hoveringDataPoint: $hoveringDataPoint)
                        DonutChart(chartDataPoints: chartDataPoints, hoveringDataPoint: $hoveringDataPoint)
                            .transition(.opacity)
                            .frame(width: min(geometry.size.height, geometry.size.width / 2), height: min(geometry.size.height, geometry.size.width / 2), alignment: .center)
                    } else {
                        DonutChart(chartDataPoints: chartDataPoints, hoveringDataPoint: $hoveringDataPoint)
                            .transition(.opacity)
                    }
                }
            } else {
                VStack {
                    DonutChart(chartDataPoints: chartDataPoints, hoveringDataPoint: $hoveringDataPoint)
                        .transition(.opacity)
                        .frame(width: min(geometry.size.height, geometry.size.width / 1.6), height: min(geometry.size.height, geometry.size.width / 1.6), alignment: .center)
                        .padding(.vertical)
                    DonutLegend(chartDataPoints: chartDataPoints, isSelected: isSelected, hoveringDataPoint: $hoveringDataPoint)
                }
            }
        }
    }
}

// MARK: - Preview
