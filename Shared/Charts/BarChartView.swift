//
//  BarChartView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 23.11.20.
//

import SwiftUI

struct BarChartView: View {
    var insightDataID: UUID
    @EnvironmentObject var api: APIRepresentative

    @Binding var topSelectedInsightID: UUID?
    private var isSelected: Bool {
        return topSelectedInsightID == insightDataID
    }

    private var insightData: InsightDataTransferObject? { api.insightData[insightDataID] }
    private var chartDataSet: ChartDataSet? {
        guard let insightData = insightData else { return nil }
        return try? ChartDataSet(data: insightData.data)
    }

    var body: some View {
        if let chartDataSet = chartDataSet {

            VStack {
                HStack {
                    GeometryReader { geometry in
                        HStack(alignment: .bottom, spacing: 1) {
                            ForEach(chartDataSet.data, id: \.self) { dataEntry in
                                BarView(data: chartDataSet, dataEntry: dataEntry, geometry: geometry)
                            }
                        }
                    }

                    if let lastValue = chartDataSet.data.last?.yAxisValue {
                        ChartRangeView(lastValue: lastValue, chartDataSet: chartDataSet, isSelected: isSelected)
                    }
                }

                ChartBottomView(insightData: insightData, isSelected: isSelected)
                    .padding(.trailing, 35)
            }
            .padding(.horizontal)
            .padding(.bottom)
        } else {
            Text("Cannot display this as a Chart")
        }
    }
}

struct BarChartView_Previews: PreviewProvider {
    static var previews: some View {
        BarChartView(insightDataID: UUID(), topSelectedInsightID: .constant(nil))
    }
}

struct BarView: View {
    let data: ChartDataSet
    let dataEntry: ChartDataPoint
    let geometry: GeometryProxy

    @State private var isHovering = false

    var body: some View {
        let percentage = CGFloat(dataEntry.yAxisValue / data.highestValue)

        VStack {
            RoundedCorners(tl: 5, tr: 5, bl: 0, br: 0)
                .fill(isHovering ? Color.accentColor : Color.accentColor.opacity(0.7))
                .frame(height: percentage.isNaN ? 0 : percentage * geometry.size.height)
                .overlay(Rectangle()
                    .foregroundColor(Color.accentColor.opacity(0.3))
                    .cornerRadius(3.0)
                    .offset(x: 0, y: 3)
                    .frame(height: 3), alignment: .bottom)
        }
        .onHover { hover in
            isHovering = hover
        }
    }
}
