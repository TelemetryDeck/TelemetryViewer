//
//  TelemetryWidget.swift
//  TelemetryWidget
//
//  Created by Daniel Jilg on 01.11.20.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), insight: MockData.exampleInsight1)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, insight: MockData.exampleInsight1)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration, insight: MockData.exampleInsight1)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let insight: InsightDataTransferObject
}

struct TelemetryWidgetEntryView : View {
    @Environment(\.widgetFamily) var size
    var entry: Provider.Entry

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(entry.insight.title.uppercased())
                    .font(.system(size: 12, weight: .medium, design: .default))
                    .foregroundColor(Color("Torange"))
                InsightNumberView(insightData: entry.insight)
                Spacer()
            }
            Spacer()
        }
        .padding()
    }
}

@main
struct TelemetryWidget: Widget {
    let kind: String = "TelemetryWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            TelemetryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct TelemetryWidget_Previews: PreviewProvider {
    static var previews: some View {
        TelemetryWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), insight: MockData.exampleInsight1))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
