//
//  TelemetryDeckWidget.swift
//  TelemetryDeckWidget
//
//  Created by Charlotte Böhm on 05.10.21.
//

import Intents
import SwiftUI
import WidgetKit

struct Provider: IntentTimelineProvider {
    let api: APIClient
    let cacheLayer: CacheLayer
    let errors: ErrorService
    let insightService: InsightService
    let insightResultService: InsightResultService

    init() {
        self.api = APIClient()
        self.cacheLayer = CacheLayer()
        self.errors = ErrorService()

        self.insightService = InsightService(api: api, cache: cacheLayer, errors: errors)
        self.insightResultService = InsightResultService(api: api, cache: cacheLayer, errors: errors)
    }

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), insightCalculationResult: .init(id: UUID.empty, insight: DTOv2.Insight(id: UUID.empty, groupID: UUID.empty, title: "foo", uniqueUser: true, filters: [:], displayMode: .raw, isExpanded: false), data: [], calculatedAt: Date(), calculationDuration: 0), chartDataSet: .init(data: [DTOv2.InsightCalculationResultRow]()))
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, insightCalculationResult: .init(id: UUID.empty, insight: DTOv2.Insight(id: UUID.empty, groupID: UUID.empty, title: "foo", uniqueUser: true, filters: [:], displayMode: .raw, isExpanded: false), data: [], calculatedAt: Date(), calculationDuration: 0), chartDataSet: ChartDataSet(data: [DTOv2.InsightCalculationResultRow](), groupBy: .day))
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        insightService.widgetableInsightIDs { uuids in
            let insightID = uuids.first!

            // get InsightCalculationResult from API

            let url = api.urlForPath(apiVersion: .v2, "insights", insightID.uuidString, "result",
                                     Formatter.iso8601noFS.string(from: Date() - 30 * 24 * 3600),
                                     Formatter.iso8601noFS.string(from: Date()))

            api.get(url) { (result: Result<DTOv2.InsightCalculationResult, TransferError>) in

                switch result {
                case .success(let insightCalculationResult):
                    let chartDataSet = ChartDataSet(data: insightCalculationResult.data, groupBy: insightCalculationResult.insight.groupBy)
                    // construct simple entry from InsightCalculationResult
                    let entry = SimpleEntry(date: insightCalculationResult.calculatedAt, configuration: configuration, insightCalculationResult: insightCalculationResult, chartDataSet: chartDataSet)
                    let timeline = Timeline(entries: [entry], policy: .atEnd)
                    completion(timeline)
                case .failure:
                    return
                }
            }
        }

        // TODO: dynamic configuration that asks for list of vegetable insights from the api
        // TODO: get selected InsightID from configuration
        // TODO: tell the timeline to reload
        // TODO: construct a real InsightCalculationResult UI similar to the main app
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let insightCalculationResult: DTOv2.InsightCalculationResult
    let chartDataSet: ChartDataSet
}

struct TelemetryDeckWidgetEntryView: View {
    let entry: Provider.Entry

    var body: some View {
        VStack {
            Text(entry.insightCalculationResult.insight.displayMode.rawValue)
//            switch entry.insightCalculationResult.insight.displayMode {
//                case .raw:
//                    RawTableView(insightData: insightData.chartDataSet, isSelected: false)
//                case .pieChart:
//                    DonutChartView(chartDataset: insightData.chartDataSet, isSelected: false)
//                case .lineChart:
//                    LineChart(chartDataSet: insightData.chartDataSet, isSelected: false)
//                case .barChart:
//                    BarChartContentView(chartDataSet: insightData.chartDataSet, isSelected: false)
//                default:
//                    Text("This is not supported in this version.")
//                        .font(.footnote)
//                        .foregroundColor(.grayColor)
//                        .padding(.vertical)
//                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//            }
        }
    }
}

@main
struct TelemetryDeckWidget: Widget {
    let kind: String = "TelemetryDeckWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            TelemetryDeckWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

// struct TelemetryDeckWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        TelemetryDeckWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), insightCalculationResult: .init(id: UUID.empty, insight: DTOv2.Insight(id: UUID.empty, groupID: UUID.empty, title: "foo", uniqueUser: true, filters: [:], displayMode: .raw, isExpanded: false), data: [], calculatedAt: Date(), calculationDuration: 0)))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
// }
