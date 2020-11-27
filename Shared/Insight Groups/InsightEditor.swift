//
//  InsightEditor.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 26.11.20.
//

import SwiftUI

struct InsightEditor: View {
    // Init Properties
    let appID: UUID
    @Binding var selectedInsightGroupID: UUID
    @Binding var selectedInsightID: UUID?

    // Environment
    @EnvironmentObject var api: APIRepresentative

    // Derived Properties
    private var app: TelemetryApp? { api.apps.first(where: { $0.id == appID }) }

    private var insightGroup: InsightGroup? {
        guard let app = app else { return nil }
        let insightGroup = api.insightGroups[app]?.first(where: { $0.id == selectedInsightGroupID })
        return insightGroup
    }

    private var insight: Insight? {
        insightGroup?.insights.first { $0.id == selectedInsightID }
    }

    // Insight State
    @State private var insightOrder: Double = -1
    @State private var insightTitle: String = ""
    @State private var insightSubtitle: String = ""
    @State private var insightSignalType: String = ""
    @State private var insightUniqueUser: Bool = false
    @State private var insightFilters: [String: String] = [:]
    @State private var insightRollingWindowSize: TimeInterval = -2592000
    @State private var insightBreakdownKey: String = ""
    @State private var insightDisplayMode: InsightDisplayMode = .lineChart
    @State private var insightIsExpanded: Bool = false

    // Updating Functions
    func updateStateWithInsight() {
        self.insightOrder = insight?.order ?? -1
        self.insightTitle = insight?.title ?? ""
        self.insightSubtitle = insight?.subtitle ?? ""
        self.insightSignalType = insight?.signalType ?? ""
        self.insightUniqueUser = insight?.uniqueUser ?? false
        self.insightFilters = insight?.filters ?? [:]
        self.insightRollingWindowSize = insight?.rollingWindowSize ?? -2592000
        self.insightBreakdownKey = insight?.breakdownKey ?? ""
        self.insightDisplayMode = insight?.displayMode ?? .lineChart
        self.insightIsExpanded = insight?.isExpanded ?? false
    }

    func saveInsight() {
        let insightDRB = InsightDefinitionRequestBody(
            order: insightOrder == -1 ? nil : insightOrder,
            title: insightTitle,
            subtitle: insightSubtitle.isEmpty ? nil : insightSubtitle,
            signalType: insightSignalType.isEmpty ? nil : insightSignalType,
            uniqueUser: insightUniqueUser,
            filters: insightFilters,
            rollingWindowSize: insightRollingWindowSize,
            breakdownKey: insightBreakdownKey.isEmpty ? nil : insightBreakdownKey,
            displayMode: insightDisplayMode,
            groupID: selectedInsightGroupID,
            id: selectedInsightID,
            isExpanded: insightIsExpanded)

        if let insight = insight, let insightGroup = insightGroup, let app = app {
            api.update(insight: insight, in: insightGroup, in: app, with: insightDRB)
        }
    }

    var padding: CGFloat? {
        #if os(macOS)
        return nil
        #else
        return 0
        #endif
    }

    // Body
    var body: some View {
        if let insightGroup = insightGroup, let insight = insight, let app = app {
            Form {
                Section(header: Text("Title, Subtitle and Group"), footer: Text("Give your insight a title, and optionally, add a longer descriptive subtitle for your insight. All insights belong to an insight group.")) {

                    TextField("Title e.g. 'Daily Active Users'", text: $insightTitle, onEditingChanged: { if !$0 { saveInsight() }}) { saveInsight() }
                    TextField("Optional Subtitle", text: $insightSubtitle, onEditingChanged: { if !$0 { saveInsight() }}) { saveInsight() }

                    Toggle(isOn: $insightIsExpanded.onUpdate(saveInsight), label: {
                        Text("Show Expanded")
                    })
//
//                    Picker(selection: $selectedInsightGroupIndex, label: Text("Insight Group")) {
//                        ForEach(0 ..< (api.insightGroups[app]?.count ?? 0)) {
//                            Text(api.insightGroups[app]?[$0].title ?? "No Title")
//                        }
//                    }.pickerStyle(WheelPickerStyle())
                }
                
                Section(header: Text("Delete")) {
                    Button("Delete this Insight") {
                        api.delete(insight: insight, in: insightGroup, in: app)
                    }
                    .accentColor(.red)
                }
            }
            .padding(.horizontal, padding)
            .onAppear {
                updateStateWithInsight()
            }
        } else {
            Text("No Insight Selected").foregroundColor(.grayColor)
        }
    }
}
