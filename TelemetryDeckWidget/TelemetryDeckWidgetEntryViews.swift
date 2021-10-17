//
//  TelemetryDeckWidgetEntryViews.swift
//  TelemetryDeckWidgetEntryViews
//
//  Created by Charlotte Böhm on 17.10.21.
//

import Intents
import SwiftUI
import WidgetKit

struct TelemetryDeckWidgetEntryView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    let entry: SimpleEntry

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            MediumTelemetryDeckWidgetEntryView(entry: entry)
        case .systemMedium:
            MediumTelemetryDeckWidgetEntryView(entry: entry)
        case .systemLarge:
            MediumTelemetryDeckWidgetEntryView(entry: entry)
        case .systemExtraLarge:
            MediumTelemetryDeckWidgetEntryView(entry: entry)
        @unknown default:
            EmptyView()
        }
    }
}

struct SmallTelemetryDeckWidgetEntryView: View {
    let entry: SimpleEntry

    var body: some View {
        VStack {
            switch entry.insightCalculationResult.insight.displayMode {
            case .raw:
                Text(entry.insightCalculationResult.insight.title.uppercased())
                    .padding(.top)
                    .font(.footnote)
                    .foregroundColor(.grayColor)
                RawTableView(insightData: entry.chartDataSet, isSelected: false)
            case .pieChart:
                DonutChartView(chartDataset: entry.chartDataSet, isSelected: false)
                    .padding()
            case .lineChart:
                Text(entry.insightCalculationResult.insight.title.uppercased())
                    .padding(.top)
                    .font(.footnote)
                    .foregroundColor(.grayColor)
                LineChart(chartDataSet: entry.chartDataSet, isSelected: false)
            case .barChart:
                Text(entry.insightCalculationResult.insight.title.uppercased())
                    .padding(.top)
                    .font(.footnote)
                    .foregroundColor(.grayColor)
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

struct MediumTelemetryDeckWidgetEntryView: View {
    let entry: SimpleEntry

    var body: some View {
        VStack {
            Text(entry.insightCalculationResult.insight.title.uppercased())
                .padding(.top)
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
