//
//  TelemetryDeckWidgetEntryViews.swift
//  TelemetryDeckWidgetEntryViews
//
//  Created by Charlotte Böhm on 17.10.21.
//

import Intents
import SwiftUI
import DataTransferObjects
import SwiftUICharts

struct TelemetryDeckWidgetEntryView: View {
    let entry: SimpleEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.insightCalculationResult.insight.title.uppercased())
                .padding(.top)
                .padding(.horizontal)
                .font(.footnote)
                .foregroundColor(.grayColor)

            switch entry.insightCalculationResult.insight.displayMode {
            case .raw:
                RawTableView(insightData: entry.chartDataSet, isSelected: false)
            case .pieChart:
                DonutChartView(chartDataset: entry.chartDataSet, isSelected: false)
                    .padding(.horizontal)
                    .padding(.bottom)
            case .lineChart:
                LineChart(chartDataSet: entry.chartDataSet, isSelected: false)
            case .barChart:
                BarChartContentView(chartDataSet: entry.chartDataSet, isSelected: false)
            default:
                Text("This is not supported in this version.")
                    .font(.footnote)
                    .foregroundColor(.grayColor)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .accentColor(Color(hex: entry.insightCalculationResult.insight.accentColor ?? "") ?? Color.telemetryOrange)
    }
}
