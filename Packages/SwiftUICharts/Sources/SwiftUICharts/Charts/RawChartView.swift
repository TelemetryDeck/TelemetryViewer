//
//  RawChartView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 22.11.20.
//

import SwiftUI

public struct SingleValueView: View {
    public init(insightData: ChartDataSet, isSelected: Bool) {
        self.insightData = insightData
        self.isSelected = isSelected
    }
    
    var insightData: ChartDataSet

    let isSelected: Bool

    let percentageFormatter: NumberFormatter = {
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        return percentageFormatter
    }()

    public var body: some View {
        VStack(alignment: .leading) {
            if let lastData = insightData.data.last,
               let doubleValue = lastData.yAxisValue,
               let dateValue = xAxisDefinition(insightData: lastData, groupBy: insightData.groupBy)
            {
                VStack(alignment: .leading) {
                    ValueAndUnitView(value: Double(doubleValue), unit: "", shouldFormatBigNumbers: true)
                        .foregroundColor(isSelected ? .cardBackground : .primary)

                    dateValue
                        .subtitleStyle()
                        .foregroundColor(isSelected ? .cardBackground : .grayColor)
                }
            } else {
                Text("\(insightData.data.last?.yAxisValue ?? 0)")
                    .valueStyle()
                    .foregroundColor(isSelected ? .cardBackground : .primary)
            }

            Spacer()

            if insightData.data.count > 1 {
                secondaryText()
                    .foregroundColor(isSelected ? .cardBackground : .grayColor)
                    .subtitleStyle()
            }
        }
    }

    func xAxisDefinition(insightData: ChartDataPoint, groupBy: InsightGroupByInterval? = .day) -> Text {
        return Text(dateString(from: insightData, groupedBy: groupBy))
    }

    func percentageString(from percentage: Double) -> String {
        let percentageNumber = NSNumber(value: percentage)
        let percentageChangeSymbol: String

        if percentage > 0 {
            percentageChangeSymbol = "▵"
        } else if percentage < 0 {
            percentageChangeSymbol = "▽"
        } else {
            percentageChangeSymbol = ""
        }

        if percentageNumber.doubleValue.isNaN {
            return "No Change"
        }

        return "\(percentageChangeSymbol)\(percentageFormatter.string(from: percentageNumber)!)"
    }

    func secondaryText() -> Text {
        guard insightData.data.count > 1 else { return Text("") }
        let previousData = insightData.data[0]

        guard let currentValue = insightData.data[1].yAxisValue, let previousValue = insightData.data[0].yAxisValue else { return xAxisDefinition(insightData: previousData, groupBy: insightData.groupBy) }

        let percentage: Double = (Double(currentValue) - Double(previousValue)) / Double(previousValue)

        return Text("\(percentageString(from: percentage)) compared to ") + xAxisDefinition(insightData: previousData, groupBy: insightData.groupBy) + Text(" (\(previousData.yAxisValue ?? 0))")
    }
}

public struct RawTableView: View {
    public init(insightData: ChartDataSet, isSelected: Bool) {
        self.insightData = insightData
        self.isSelected = isSelected
    }
    
    var insightData: ChartDataSet

    let isSelected: Bool

    private let columns = [
        GridItem(.flexible(maximum: 200), spacing: nil, alignment: .leading),
        GridItem(.flexible(), spacing: nil, alignment: .trailing),
    ]

    public var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                if let data = insightData.data {
                    ForEach(data, id: \.xAxisValue) { dataRow in
                        Group {
                            Text(dateString(from: dataRow, groupedBy: insightData.groupBy))
                                .font(.footnote)
                                .foregroundColor(isSelected ? .cardBackground : .grayColor)

                            ValueView(value: Double(dataRow.yAxisValue ?? 0), shouldFormatBigNumbers: true)
                                        .foregroundColor(isSelected ? .cardBackground : .none)

                            .foregroundColor(isSelected ? .cardBackground : .none)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

func dateString(from chartDataPoint: ChartDataPoint, groupedBy groupByInterval: InsightGroupByInterval?) -> String {
    guard let date = chartDataPoint.xAxisDate else { return chartDataPoint.xAxisValue }

    let formatter = DateFormatter()

    if let groupByInterval = groupByInterval {
        switch groupByInterval {
        case .hour:
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: date)
        case .day:
            formatter.dateStyle = .long
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            return formatter.string(from: date)
        case .week:
            formatter.dateStyle = .long
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            return "Week of \(formatter.string(from: date))"
        case .month:
            formatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            return formatter.string(from: date)
        }
    }

    return "\(date)"
}
