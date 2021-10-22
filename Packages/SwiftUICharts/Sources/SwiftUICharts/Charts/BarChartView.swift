//
//  BarChartView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 23.11.20.
//

import SwiftUI

public struct BarChartContentView: View {
    public init(chartDataSet: ChartDataSet, isSelected: Bool) {
        self.chartDataSet = chartDataSet
        self.isSelected = isSelected
    }
    
    let chartDataSet: ChartDataSet
    let isSelected: Bool

    @State var hoveringDataEntry: ChartDataPoint?

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                HStack {
                    GeometryReader { geometry in
                        HStack(alignment: .bottom, spacing: 1) {
                            ForEach(chartDataSet.data) { dataEntry in
                                BarView(dataSet: chartDataSet, dataEntry: dataEntry, geometry: geometry, isHovering: dataEntry == hoveringDataEntry)
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

                            if geometry.size.width > 300, let lastValue = chartDataSet.data.last?.yAxisValue {
                                    ChartRangeView(lastValue: Double(lastValue), chartDataSet: chartDataSet, isSelected: isSelected)
                                }
                            }
                        
                    }
                }

                ChartBottomView(insightData: chartDataSet, isSelected: isSelected)
                    .padding(.trailing, 35)
            }
            .padding(.horizontal)
            .padding(.bottom)

            if hoveringDataEntry != nil {
                ChartHoverLabel(dataEntry: hoveringDataEntry!, interval: chartDataSet.groupBy ?? .day)
                    .padding()
            }
        }
    }
}

struct BarView: View {
    let dataSet: ChartDataSet
    let dataEntry: ChartDataPoint
    let geometry: GeometryProxy
    let isHovering: Bool

    var body: some View {
        if let yAxisValue = dataEntry.yAxisValue {
            let percentage = CGFloat(yAxisValue) / CGFloat(dataSet.highestValue)

            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(dataSet.isCurrentPeriod(dataEntry) ? .accentColor.opacity(0.1) : Color.clear)

                RoundedCorners(tl: 5, tr: 5, bl: 0, br: 0)
                    .fill(isHovering ? Color.grayColor.opacity(dataSet.isCurrentPeriod(dataEntry) ? 0.4 : 0.6) : Color.accentColor.opacity(dataSet.isCurrentPeriod(dataEntry) ? 0.5 : 0.7))
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
