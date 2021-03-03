//
//  AppRootView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 17.02.21.
//

import SwiftUI

struct AppRootView: View {
    @EnvironmentObject var api: APIRepresentative
    let app: TelemetryApp

    @State var selection: AppRootViewSelection = .noSelection

    private var insightGroup: InsightGroup? {
        switch selection {
        case .insightGroup(let group):
            return group
        default:
            return nil
        }
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    var timeIntervalDescription: String {
        let displayTimeWindowEnd = api.timeWindowEnd ?? Date()
        let displayTimeWindowBegin = api.timeWindowBeginning ??
            displayTimeWindowEnd.addingTimeInterval(-60 * 60 * 24 * 30)

        if api.timeWindowEnd == nil {
            if api.timeWindowBeginning == nil {
                return "Showing Last 30 Days"
            } else {
                let components = Calendar.current.dateComponents([.day], from: displayTimeWindowBegin, to: displayTimeWindowEnd)
                return "Showing Last \(components.day ?? 0) Days"
            }
        } else {
            return "\(dateFormatter.string(from: displayTimeWindowBegin)) – \(dateFormatter.string(from: displayTimeWindowEnd))"
        }
    }


    func reloadVisibleInsights() {
        guard let insightGroup = insightGroup else { return }

        for insight in insightGroup.insights {
            api.getInsightData(for: insight, in: insightGroup, in: app)
        }
    }


    var body: some View {
        Group {
            switch selection {
            case .lexicon:
                LexiconView(appID: app.id)
            case .rawSignals:
                SignalList(appID: app.id)
            case .insightGroup(let group):
                InsightGroupView(app: app, insightGroup: group)
            case .noSelection:
                Text("Hi!")
            }
        }
        .navigationTitle(app.name)
        .onAppear {
            if let firstInsightGroup = api.insightGroups[app]?.first, selection == .noSelection {
                selection = .insightGroup(group: firstInsightGroup)
            }
        }
        .toolbar {
            Spacer()

            Picker("View Mode", selection: $selection) {
                ForEach(api.insightGroups[app] ?? []) { insightGroup in
                    Text(insightGroup.title).tag(AppRootViewSelection.insightGroup(group: insightGroup))
                }

                Image(systemName: "book")
                    .tag(AppRootViewSelection.lexicon)
                    .help("Lexicon")
                Image(systemName: "waveform")
                    .tag(AppRootViewSelection.rawSignals)
                    .help("Raw Signals")
            }.pickerStyle(SegmentedPickerStyle())

            Spacer()
                Menu {
                    Section {
                        Button(action: {
                            api.timeWindowBeginning = Date().addingTimeInterval(-60 * 60 * 24 * 365)
                            api.timeWindowEnd = nil
                            reloadVisibleInsights()
                        }) {
                            Label("Last Year", systemImage: "calendar")
                        }

                        Button(action: {
                            api.timeWindowBeginning = nil
                            api.timeWindowEnd = nil
                            reloadVisibleInsights()
                        }) {
                            Label("Last Month", systemImage: "calendar")
                        }

                        Button(action: {
                            api.timeWindowBeginning = Date().addingTimeInterval(-60 * 60 * 24 * 7)
                            api.timeWindowEnd = nil
                            reloadVisibleInsights()
                        }) {
                            Label("Last Week", systemImage: "calendar")
                        }

                        Button(action: {
                            api.timeWindowBeginning = Date().addingTimeInterval(-60 * 60 * 24)
                            api.timeWindowEnd = nil
                            reloadVisibleInsights()
                        }) {
                            Label("Today", systemImage: "calendar")
                        }
                    }
                }
                label: {
                    Text(timeIntervalDescription)
                }


            Spacer()

            if let insightGroup = insightGroup {
                Button(action: {
                    let definitionRequestBody = InsightDefinitionRequestBody.new(groupID: insightGroup.id)
                    api.create(insightWith: definitionRequestBody, in: insightGroup, for: app) { _ in api.getInsightGroups(for: app) }
                }) {
                    Label("New Insight", systemImage: "plus.rectangle")
                }
                .help("New Insight")
            }
        }
    }
}
