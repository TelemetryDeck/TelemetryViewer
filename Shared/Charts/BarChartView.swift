//
//  BarChartView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 23.11.20.
//

import SwiftUI

struct BarChartView: View {
    @EnvironmentObject var insightCalculationService: InsightCalculationService

    let insightID: UUID
    let insightGroupID: UUID
    let appID: UUID

    @Binding var topSelectedInsightID: UUID?
    private var isSelected: Bool {
        topSelectedInsightID == insightID
    }

    var body: some View {
        if let insightData = insightCalculationService.insightData(for: insightID, in: insightGroupID, in: appID), let chartDataSet = try? ChartDataSet(data: insightData.data) {
            BarChartContentView(insightCalculationResult: insightData, chartDataSet: chartDataSet, isSelected: isSelected)
        } else {
            Text("Cannot display this as a Chart")
        }
    }
}

struct BarChartContentView: View {
    let insightCalculationResult: DTO.InsightCalculationResult
    let chartDataSet: ChartDataSet
    let isSelected: Bool

    @State var hoveringDataEntry: DTO.InsightData?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                HStack {
                    GeometryReader { geometry in
                        HStack(alignment: .bottom, spacing: 1) {
                            ForEach(insightCalculationResult.data, id: \.self) { dataEntry in
                                BarView(insightCalculationResult: insightCalculationResult, dataEntry: dataEntry, geometry: geometry, isHovering: dataEntry == hoveringDataEntry)
                                    .onHover { over in
                                        withAnimation {
                                            if over {
                                                hoveringDataEntry = dataEntry
                                            } else {
                                                hoveringDataEntry = nil
                                            }
                                        }
                                    }
                                #if os(iOS)
                                    .onTapGesture {
                                        hoveringDataEntry = dataEntry
                                    }
                                #endif
                            }
                        }
                    }

                    if let lastValue = insightCalculationResult.data.last?.yAxisDouble {
                        ChartRangeView(lastValue: lastValue, chartDataSet: chartDataSet, isSelected: isSelected)
                    }
                }

                ChartBottomView(insightData: insightCalculationResult, isSelected: isSelected)
                    .padding(.trailing, 35)
            }
            .padding(.horizontal)
            .padding(.bottom)

            if hoveringDataEntry != nil {
                ChartHoverLabel(dataEntry: hoveringDataEntry!, interval: insightCalculationResult.groupBy ?? .day)
                    .padding()
            }
        }
    }
}

struct BarView: View {
    let insightCalculationResult: DTO.InsightCalculationResult
    let dataEntry: DTO.InsightData
    let geometry: GeometryProxy
    let isHovering: Bool

    /// `true` if the bar represents the current day/week/month/etc, and therefore represents
    /// incomplete data.
    var isCurrentPeriod: Bool {
        let groupByPeriod = insightCalculationResult.groupBy ?? .day

        guard let date = dataEntry.xAxisDate else { return false }

        switch groupByPeriod {
        case .hour:
            return date.isInCurrent(.hour)
        case .day:
            return date.isInToday
        case .week:
            return date.isInCurrentWeek
        case .month:
            return date.isInCurrentMonth
        }
    }

    var body: some View {
        if let yAxisValue = dataEntry.yAxisDouble {
            let percentage = CGFloat(yAxisValue / insightCalculationResult.highestValue)

            ZStack(alignment: .bottom) {
                RoundedCorners(tl: 5, tr: 5, bl: 0, br: 0)
                    .fill(isHovering ? Color.grayColor.opacity(isCurrentPeriod ? 0.4 : 0.6) : Color.accentColor.opacity(isCurrentPeriod ? 0.5 : 0.7))
                    .frame(height: percentage.isNaN ? 0 : percentage * geometry.size.height)

                Rectangle()
                    .foregroundColor(isHovering ? Color.grayColor.opacity(0.3) : Color.accentColor.opacity(0.3))
                    .cornerRadius(3.0)
                    .offset(x: 0, y: 3)
                    .frame(height: 3)
            }
            .animation(.none)
        } else {
            EmptyView()
        }
    }
}

struct Barchart_Previews: PreviewProvider {
    static var previews: some View {
        let calculationData = [
            DTO.InsightData(xAxisValue: "2021-06-25T00:00:00.000Z", yAxisValue: "12123"),
            DTO.InsightData(xAxisValue: "2021-06-26T00:00:00.000Z", yAxisValue: "13423"),
            DTO.InsightData(xAxisValue: "2021-06-27T00:00:00.000Z", yAxisValue: "12456"),
            DTO.InsightData(xAxisValue: "2021-06-28T00:00:00.000Z", yAxisValue: "15234"),
            DTO.InsightData(xAxisValue: "2021-06-29T00:00:00.000Z", yAxisValue: "18789"),
            DTO.InsightData(xAxisValue: "2021-06-30T00:00:00.000Z", yAxisValue: "21234"),
            DTO.InsightData(xAxisValue: "2021-07-01T00:00:00.000Z", yAxisValue: "28789"),
            DTO.InsightData(xAxisValue: "2021-07-02T00:00:00.000Z", yAxisValue: "38234"),
            DTO.InsightData(xAxisValue: "2021-07-03T00:00:00.000Z", yAxisValue: "39678"),
            DTO.InsightData(xAxisValue: "2021-07-04T00:00:00.000Z", yAxisValue: "55234"),
            DTO.InsightData(xAxisValue: "2021-07-05T00:00:00.000Z", yAxisValue: "70164"),
            DTO.InsightData(xAxisValue: "2021-07-06T00:00:00.000Z", yAxisValue: "19445"),
        ]

        let calculationResult = DTO.InsightCalculationResult(
            id: UUID(),
            order: nil,
            title: "How Deep Is Your Love?",
            subtitle: nil,
            signalType: nil,
            uniqueUser: false,
            filters: [:],
            rollingWindowSize: 0,
            breakdownKey: nil,
            groupBy: .day,
            displayMode: .barChart,
            isExpanded: false,
            data: calculationData,
            calculatedAt: Date(),
            calculationDuration: 12,
            shouldUseDruid: true)

        BarChartContentView(insightCalculationResult: calculationResult, chartDataSet: try! ChartDataSet(data: calculationResult.data), isSelected: false)
            .padding()
    }
}
