//
//  TelemetryDeckWidget.swift
//  TelemetryDeckWidget
//
//  Created by Charlotte Böhm on 05.10.21.
//

import DataTransferObjects
import Intents
import SwiftUI
import SwiftUICharts
import TelemetryClient
import WidgetKit

struct Provider: IntentTimelineProvider {
    let api: APIClient
    let cacheLayer: CacheLayer
    let errors: ErrorService
    let insightService: InsightService
    let insightResultService: InsightResultService

    init() {
        let configuration = TelemetryManagerConfiguration(appID: "79167A27-EBBF-4012-9974-160624E5D07B")
        TelemetryManager.initialize(with: configuration)

        self.api = APIClient()
        self.cacheLayer = CacheLayer()
        self.errors = ErrorService()

        self.insightService = InsightService(api: api, cache: cacheLayer, errors: errors)
        self.insightResultService = InsightResultService(api: api, cache: cacheLayer, errors: errors)
    }

    func placeholder(in context: Context) -> SimpleEntry {
        let integer = Int.random(in: 0...4)
        let result: DTOv2.InsightCalculationResult = insightCalculationResults[integer]
        let dataSet = ChartDataSet(data: result.data, groupBy: result.insight.groupBy)
        return SimpleEntry(date: Date(), configuration: ConfigurationIntent(), insightCalculationResult: result, chartDataSet: dataSet)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let integer = Int.random(in: 0...4)
        let result: DTOv2.InsightCalculationResult = insightCalculationResults[integer]
        let dataSet = ChartDataSet(data: result.data, groupBy: result.insight.groupBy)
        let entry = SimpleEntry(date: Date(), configuration: configuration, insightCalculationResult: result, chartDataSet: dataSet)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        guard configuration.Insight?.identifier != nil else { return }

        guard configuration.Insight?.identifier != "00000000-0000-0000-0000-000000000000" else {
            let integer = Int.random(in: 0...4)
            let result: DTOv2.InsightCalculationResult = insightCalculationResults[integer]
            let dataSet = ChartDataSet(data: result.data, groupBy: result.insight.groupBy)
            let entry = SimpleEntry(date: Date(), configuration: configuration, insightCalculationResult: result, chartDataSet: dataSet, widgetDisplayMode: .chooseInsightView)
            let timeline = Timeline(entries: [entry], policy: .after(Date() + 2 * 60 * 60))
            completion(timeline)
            return
        }

        let insightID = UUID(uuidString: (configuration.Insight!.identifier)!)!
        
        let interval = TimeInterval(configuration.Interval?.intValue ?? 30)

        // get InsightCalculationResult from API
        let url = api.urlForPath(apiVersion: .v2, "insights", insightID.uuidString, "result",
                                 Formatter.iso8601noFS.string(from: Date() - interval * 24 * 3600),
                                 Formatter.iso8601noFS.string(from: Date()))

        api.get(url) { (result: Result<DTOv2.InsightCalculationResult, TransferError>) in
            switch result {
            case .success(let insightCalculationResult):
                let chartDataSet = ChartDataSet(data: insightCalculationResult.data, groupBy: insightCalculationResult.insight.groupBy)
                // construct simple entry from InsightCalculationResult
                let entry = SimpleEntry(date: insightCalculationResult.calculatedAt, configuration: configuration, insightCalculationResult: insightCalculationResult, chartDataSet: chartDataSet, widgetDisplayMode: .normalView)
                let timeline = Timeline(entries: [entry], policy: .after(Date() + 2 * 60 * 60))
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
    var widgetDisplayMode: widgetDisplayMode = .placeholderView
}

enum widgetDisplayMode {
    case placeholderView
    case chooseInsightView
    case normalView
}

@main
struct TelemetryDeckWidget: Widget {
    let kind: String = "TelemetryDeckWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            TelemetryDeckWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Telemetry Deck Widget")
        .description("If no Insights are available here, make sure you are logged in. You can search for Insights by name, app, or display type")
    }
}

struct TelemetryDeckWidget_Previews: PreviewProvider {
    static var previews: some View {
        let result: DTOv2.InsightCalculationResult = insightCalculationResults[2]
        let entry = SimpleEntry(date: Date(), configuration: ConfigurationIntent(), insightCalculationResult: result, chartDataSet: ChartDataSet(data: result.data, groupBy: result.insight.groupBy), widgetDisplayMode: .chooseInsightView)
        TelemetryDeckWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        TelemetryDeckWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        TelemetryDeckWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
        if #available(iOSApplicationExtension 15.0, *) {
            TelemetryDeckWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
        }
    }
}
