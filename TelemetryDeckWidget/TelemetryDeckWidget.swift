//
//  TelemetryDeckWidget.swift
//  TelemetryDeckWidget
//
//  Created by Charlotte Böhm on 05.10.21.
//

import Intents
import SwiftUI
import TelemetryClient
import WidgetKit
import DataTransferObjects
import SwiftUICharts
import TelemetryDeckClient

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

        let insightID = UUID(uuidString: (configuration.Insight!.identifier)!)!

        // get InsightCalculationResult from API
        let url = api.urlForPath(apiVersion: .v2, "insights", insightID.uuidString, "result",
                                 Formatter.iso8601noFS.string(from: Date().beginning(of: .month) ?? Date() - 30 * 24 * 3600),
                                 Formatter.iso8601noFS.string(from: Date()))

        api.get(url) { (result: Result<DTOv2.InsightCalculationResult, TransferError>) in
            switch result {
            case .success(let insightCalculationResult):
                let chartDataSet = ChartDataSet(data: insightCalculationResult.data, groupBy: insightCalculationResult.insight.groupBy)
                // construct simple entry from InsightCalculationResult
                let entry = SimpleEntry(date: insightCalculationResult.calculatedAt, configuration: configuration, insightCalculationResult: insightCalculationResult, chartDataSet: chartDataSet)
                let timeline = Timeline(entries: [entry], policy: .after(Date() + 2 * 60 * 60))
                completion(timeline)
            case .failure:
                return
            }
        }

        // done: dynamic configuration that asks for list of vegetable insights from the api
        // done: get selected InsightID from configuration
        // done: tell the timeline to reload
        // done: construct a real InsightCalculationResult UI similar to the main app
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let insightCalculationResult: DTOv2.InsightCalculationResult
    let chartDataSet: ChartDataSet
}

@main
struct TelemetryDeckWidget: Widget {
    let kind: String = "TelemetryDeckWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            TelemetryDeckWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Telemetry Deck Widget")
        .description("Go to the app's insight editor to make an insight available for this widget.")
    }
}

struct TelemetryDeckWidget_Previews: PreviewProvider {
    static var previews: some View {
        let result: DTOv2.InsightCalculationResult = insightCalculationResults[4]
        let entry = SimpleEntry(date: Date(), configuration: ConfigurationIntent(), insightCalculationResult: result, chartDataSet: ChartDataSet(data: result.data, groupBy: result.insight.groupBy))
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
