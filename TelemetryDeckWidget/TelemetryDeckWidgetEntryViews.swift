//
//  TelemetryDeckWidgetEntryViews.swift
//  TelemetryDeckWidgetEntryViews
//
//  Created by Charlotte Böhm on 17.10.21.
//

import DataTransferObjects
import Intents
import SwiftUI
import SwiftUICharts

struct TelemetryDeckWidgetEntryView: View {
    let entry: SimpleEntry

    var body: some View {
        GeometryReader { geometry in
            ZStack() {
                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.configuration.Insight?.appName ?? "" + " string" + entry.insightCalculationResult.insight.title.uppercased())
                        .padding(.top)
                        .padding(.horizontal)
                        .font(Font.system(size: 12))
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
                        BarChartView(chartDataSet: entry.chartDataSet, isSelected: false)
                    default:
                        Text("This is not supported in this version.")
                            .font(.footnote)
                            .foregroundColor(.grayColor)
                            .padding(.vertical)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                }
                .accentColor(Color(hex: entry.insightCalculationResult.insight.accentColor ?? "") ?? Color.telemetryOrange)
                if entry.configuration.Insight?.identifier == "00000000-0000-0000-0000-000000000000" {
                    
                    Rectangle()
                        .fill(Color.grayColor.opacity(0.5))
                        .frame(width: geometry.size.width, height: geometry.size.height)


                    Text("Please select an Insight in this Widget's options".uppercased())
                        .multilineTextAlignment(.center)
                        .unredacted()
                        .font(Font.system(size: 20))
                        .foregroundColor(Color.primary)
                }
            }
        }
    }
}
