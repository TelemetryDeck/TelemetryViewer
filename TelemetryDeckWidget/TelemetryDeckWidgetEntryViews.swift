//
//  TelemetryDeckWidgetEntryViews.swift
//  TelemetryDeckWidgetEntryViews
//
//  Created by Charlotte Böhm on 17.10.21.
//

import DataTransferObjects
import Intents
import SwiftUI

import WidgetKit

struct TelemetryDeckWidgetEntryView: View {
    let entry: SimpleEntry

    @Environment(\.widgetFamily) var family: WidgetFamily

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text((entry.configuration.ShowAppName?.boolValue ?? false) ?
                        (entry.configuration.Insight?.appName ?? "Example App").uppercased() + " • " + entry.insightCalculationResult.insight.title.uppercased() : entry.insightCalculationResult.insight.title.uppercased())
                        .padding(.top)
                        .padding(.horizontal)
                        .font(Font.system(size: family == .systemSmall ? 10 : 12))
                        .foregroundColor(.grayColor)

                    switch entry.insightCalculationResult.insight.displayMode {
                    case .raw:
                        RawChartView(chartDataSet: entry.chartDataSet, isSelected: false)
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
                .if(entry.widgetDisplayMode == .chooseInsightView) { $0.blur(radius: 1.5) }
                if entry.widgetDisplayMode == .chooseInsightView {
                    Rectangle()
                        .fill(Color.cardBackground.opacity(0.1))
                        .frame(width: geometry.size.width, height: geometry.size.height)

                    Text("Please select an Insight in this Widget's options".uppercased())
                        .multilineTextAlignment(.center)
                        .unredacted()
                        .font(Font.system(size: 15))
                        .foregroundColor(Color.primary)
                        .shadow(color: Color.cardBackground, radius: 16)
                        .padding()
                }
            }
            .if(entry.widgetDisplayMode == .chooseInsightView || entry.widgetDisplayMode == .placeholderView) { $0.redacted(reason: .placeholder) }
        }
    }
}
