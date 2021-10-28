//
//  ServiceRawChartView.swift
//  Telemetry Viewer (iOS)
//
//  Created by Daniel Jilg on 20.07.21.
//

import SwiftUI
import DataTransferObjects
import SwiftUICharts

struct RawChartView: View {
    let chartDataSet: ChartDataSet
    let isSelected: Bool

    var body: some View {
        if chartDataSet.data.count > 2 || chartDataSet.data.first?.xAxisDate == nil {
            RawTableView(insightData: chartDataSet, isSelected: isSelected)
        } else {
            SingleValueView(insightData: chartDataSet, isSelected: isSelected)
                .frame(minWidth: 0,
                       maxWidth: .infinity,
                       minHeight: 0,
                       maxHeight: .infinity,
                       alignment: .topLeading)
                .padding(.bottom)
                .padding(.horizontal)
        }
    }
}
