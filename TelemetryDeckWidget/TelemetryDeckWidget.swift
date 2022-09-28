//
//  TelemetryDeckWidget.swift
//  TelemetryDeckWidget
//
//  Created by Charlotte Böhm on 05.10.21.
//

import DataTransferObjects
import Intents
import SwiftUI

import TelemetryClient
import WidgetKit

struct Provider: IntentTimelineProvider {
    let api: APIClient

    init() {
        let configuration = TelemetryManagerConfiguration(appID: "79167A27-EBBF-4012-9974-160624E5D07B")
        TelemetryManager.initialize(with: configuration)

        self.api = APIClient()
    }

    func placeholder(in context: Context) -> SimpleEntry {
        let integer = Int.random(in: 0...4)
        let result: DTOv2.InsightCalculationResult = insightCalculationResults[integer]
        let dataSet = ChartDataSet(data: result.data, groupBy: result.insight.groupBy)
        return SimpleEntry(date: Date(), configuration: ConfigurationIntent(), insightCalculationResult: result, chartDataSet: dataSet)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let integer = Int.random(in: 0...4)
        let result: DTOv2.InsightCalculationResult = insightCalculationResults[integer]
        let dataSet = ChartDataSet(data: result.data, groupBy: result.insight.groupBy)
        let entry = SimpleEntry(date: Date(), configuration: configuration, insightCalculationResult: result, chartDataSet: dataSet)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        guard configuration.Insight?.identifier != nil else { return }

        guard configuration.Insight?.identifier != "00000000-0000-0000-0000-000000000000" else {
            let integer = Int.random(in: 0...4)
            let result: DTOv2.InsightCalculationResult = insightCalculationResults[integer]
            let dataSet = ChartDataSet(data: result.data, groupBy: result.insight.groupBy)
            let entry = SimpleEntry(date: Date(), configuration: configuration, insightCalculationResult: result, chartDataSet: dataSet, widgetDisplayMode: .chooseInsightView)
            let timeline = Timeline(entries: [entry], policy: .after(Date() + 2 * 60 * 60))
            TelemetryManager.send("NewWidgetCreated")
            completion(timeline)
            return
        }

        let insightID = UUID(uuidString: (configuration.Insight!.identifier)!)!

        var interval = TimeInterval(configuration.Interval?.intValue ?? 30 * 24 * 3600)

        if interval == 0 { interval = 30 * 24 * 3600 }
        if interval < (24 * 3600) { interval = 24 * 3600 }
        if interval > (300 * 24 * 3600) { interval = 300 * 24 * 3600 }

        let endDate = Date().endOfDay
        let beginDate = (endDate - interval).beginning(of: .day) ?? (endDate - interval)

        // get InsightCalculationResult from API
        let url = api.urlForPath(apiVersion: .v2, "insights", insightID.uuidString, "result",
                                 Formatter.iso8601noFS.string(from: beginDate),
                                 Formatter.iso8601noFS.string(from: endDate))

        api.get(url) { (result: Result<DTOv2.InsightCalculationResult, TransferError>) in
            switch result {
            case .success(let insightCalculationResult):
                let chartDataSet = ChartDataSet(data: insightCalculationResult.data, groupBy: insightCalculationResult.insight.groupBy)
                // construct simple entry from InsightCalculationResult
                let entry = SimpleEntry(
                    date: insightCalculationResult.calculatedAt,
                    configuration: configuration,
                    insightCalculationResult: insightCalculationResult,
                    chartDataSet: chartDataSet,
                    widgetDisplayMode: .normalView
                )
                let timeline = Timeline(entries: [entry], policy: .after(Date() + 2 * 60 * 60))
                TelemetryManager.send("WidgetReloaded", with: ["WidgetChartType": entry.insightCalculationResult.insight.displayMode.rawValue, "WidgetSize": context.family.description])
                completion(timeline)
            case .failure:
                return
            }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let insightCalculationResult: DTOv2.InsightCalculationResult
    let chartDataSet: ChartDataSet
    var widgetDisplayMode: WidgetDisplayMode = .placeholderView
}

enum WidgetDisplayMode {
    case placeholderView
    case chooseInsightView
    case normalView
}

@main
struct TelemetryDeckWidget: Widget {
    let kind: String = "TelemetryDeckWidget"
    
    func supportedFamilies() -> [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            return [.accessoryRectangular, .systemSmall, .systemMedium, .systemLarge, .systemExtraLarge]
        } else {
            return [.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge]
        }
    }

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            TelemetryDeckWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Telemetry Deck Widget")
        .description("If no Insights are available here, make sure you are logged in. You can search for Insights by name, app, or display type")
        .supportedFamilies(supportedFamilies())
    }
}

struct TelemetryDeckWidget_Previews: PreviewProvider {
    static var previews: some View {
        let result: DTOv2.InsightCalculationResult = insightCalculationResults[3]
        let result2: DTOv2.InsightCalculationResult = insightCalculationResults[2]
        let entry = SimpleEntry(
            date: Date(),
            configuration: ConfigurationIntent(),
            insightCalculationResult: result,
            chartDataSet: ChartDataSet(data: result.data, groupBy: result.insight.groupBy),
            widgetDisplayMode: .normalView
        )
        let entry2 = SimpleEntry(
            date: Date(),
            configuration: ConfigurationIntent(),
            insightCalculationResult: result2,
            chartDataSet: ChartDataSet(data: result2.data, groupBy: result2.insight.groupBy),
            widgetDisplayMode: .normalView
        )
        if #available(iOSApplicationExtension 16.0, *) {
            TelemetryDeckWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        } else {
            // Fallback on earlier versions
        }
        TelemetryDeckWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        TelemetryDeckWidgetEntryView(entry: entry2)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        TelemetryDeckWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        TelemetryDeckWidgetEntryView(entry: entry2)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        TelemetryDeckWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
        #if os(iOS)
        if #available(iOSApplicationExtension 15.0, *) {
            TelemetryDeckWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
        }
        #endif
    }
}
