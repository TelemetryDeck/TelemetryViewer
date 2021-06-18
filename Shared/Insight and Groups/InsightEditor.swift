//
//  InsightEditor.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 17.02.21.
//

import SwiftUI

struct InsightEditorContent {
    var order: Double
    var title: String

    /// Which signal types are we interested in? If empty, do not filter by signal type
    var signalType: String

    /// If true, only include at the newest signal from each user
    var uniqueUser: Bool

    /// Only include signals that match all of these key-values in the payload
    var filters: [String: String]

    /// How far to go back to aggregate signals
    var rollingWindowSize: TimeInterval

    /// If set, break down the values in this key
    var breakdownKey: String

    /// If set, group and count found signals by this time interval. Incompatible with breakdownKey
    var groupBy: InsightGroupByInterval

    /// How should this insight's data be displayed?
    var displayMode: InsightDisplayMode

    /// Which group should the insight belong to? (Only use this in update mode)
    var groupID: UUID

    /// The ID of the insight
    var id: UUID

    /// If true, the insight will be displayed bigger
    var isExpanded: Bool

    /// Should use druid for calculating this insght
    var shouldUseDruid: Bool

    static func empty() -> InsightEditorContent {
        return Self(
            order: -1,
            title: "...",
            signalType: "",
            uniqueUser: false,
            filters: [:],
            rollingWindowSize: 0,
            breakdownKey: "",
            groupBy: .day,
            displayMode: .number,
            groupID: UUID(),
            id: UUID(),
            isExpanded: false,
            shouldUseDruid: true
        )
    }

    static func from(insight: DTO.InsightDTO) -> InsightEditorContent {
        let requestBody = Self(
            order: insight.order ?? -1,
            title: insight.title,
            signalType: insight.signalType ?? "",
            uniqueUser: insight.uniqueUser,
            filters: insight.filters,
            rollingWindowSize: insight.rollingWindowSize,
            breakdownKey: insight.breakdownKey ?? "",
            groupBy: insight.groupBy ?? .day,
            displayMode: insight.displayMode,
            groupID: insight.group["id"]!,
            id: insight.id,
            isExpanded: insight.isExpanded,
            shouldUseDruid: insight.shouldUseDruid
        )

        return requestBody
    }

    func insightDefinitionRequestBody() -> InsightDefinitionRequestBody {
        InsightDefinitionRequestBody(
            order: order,
            title: title,
            subtitle: nil,
            signalType: signalType.isEmpty ? nil : signalType,
            uniqueUser: uniqueUser,
            filters: filters,
            rollingWindowSize: rollingWindowSize,
            breakdownKey: breakdownKey.isEmpty ? nil : breakdownKey,
            groupBy: breakdownKey.isEmpty ? groupBy : nil,
            displayMode: displayMode,
            groupID: groupID,
            id: id,
            isExpanded: isExpanded,
            shouldUseDruid: shouldUseDruid
        )
    }
}

struct InsightEditor: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var insightService: InsightService
    @EnvironmentObject var insightCalculationService: InsightCalculationService
    @EnvironmentObject var lexiconService: LexiconService

    @State private var showingAlert = false
    @State var editorContent: InsightEditorContent

    let appID: UUID
    let insightGroupID: UUID

    func save() {
        insightService.update(insightID: editorContent.id, in: insightGroupID, in: appID, with: editorContent.insightDefinitionRequestBody()) { _ in
            insightCalculationService.getInsightData(for: editorContent.id, in: insightGroupID, in: appID)
        }
    }

    func updatePayloadKeys() {
        lexiconService.getSignalTypes(for: appID)
        lexiconService.getPayloadKeys(for: appID)
    }

    var chartTypeExplanationText: String {
        switch editorContent.displayMode {
        case .number:
            return "Currently, 'Number' is the selected Chart Type. This chart type is no longer supported, and you should choose the 'Raw' instead."
        case .raw:
            return "Displays the insight's data directly as numbers."
        case .barChart:
            return "Displays a bar chart for the insight's data."
        case .lineChart:
            return "Displays a line chart for the insight's data."
        case .pieChart:
            return "Displays a pie chart for the insight's data. This is especially helpful in combination with the 'breakdown' function."
        }
    }

    var chartImage: Image {
        switch editorContent.displayMode {
        case .raw:
            return Image(systemName: "number.square.fill")
        case .barChart:
            return Image(systemName: "chart.bar.fill")
        case .lineChart:
            return Image(systemName: "squares.below.rectangle")
        case .pieChart:
            return Image(systemName: "chart.pie.fill")
        default:
            return Image(systemName: "number.square")
        }
    }

    var filterAutocompletionOptions: [String] {
        return lexiconService.payloadKeys(for: appID).filter { !$0.isHidden }.map(\.payloadKey)
    }

    var signalTypeAutocompletionOptions: [String] {
        return lexiconService.signalTypes(for: appID).map(\.type)
    }

    var insightGroupTitle: String {
        return insightService.insightGroup(id: insightGroupID, in: appID)?.title ?? "–"
    }

    var body: some View {
        let form = Form {
            CustomSection(header: Text("Name"), summary: Text(insightCalculationService.insightData(for: editorContent.id, in: insightGroupID, in: appID)?.title ?? "..."), footer: Text("The Title of This Insight")) {
                TextField("Title e.g. 'Daily Active Users'", text: $editorContent.title, onEditingChanged: { _ in save() }, onCommit: { save() })

                #if os(macOS)
                    Toggle(isOn: $editorContent.isExpanded, label: {
                        Text("Show Expanded")
                    })
                        .onChange(of: editorContent.isExpanded) { _ in save() }
                #endif
            }

            CustomSection(header: Text("Chart Type"), summary: chartImage, footer: Text(chartTypeExplanationText), startCollapsed: true) {
                Picker(selection: $editorContent.displayMode, label: Text("")) {
                    Image(systemName: "number.square.fill").tag(InsightDisplayMode.raw)
                    Image(systemName: "chart.bar.fill").tag(InsightDisplayMode.barChart)
                    Image(systemName: "squares.below.rectangle").tag(InsightDisplayMode.lineChart)
                    Image(systemName: "chart.pie.fill").tag(InsightDisplayMode.pieChart)
                }
                .onChange(of: editorContent.displayMode) { _ in save() }
                .pickerStyle(SegmentedPickerStyle())
            }

            if editorContent.breakdownKey.isEmpty {
                CustomSection(header: Text("Group Values by"), summary: Text(editorContent.groupBy.rawValue), footer: Text("Group signals by time interval. The more fine-grained the grouping, the more separate values you'll receive."), startCollapsed: true) {
                    Picker(selection: $editorContent.groupBy, label: Text("")) {
                        Text("Hour").tag(InsightGroupByInterval.hour)
                        Text("Day").tag(InsightGroupByInterval.day)
                        Text("Week").tag(InsightGroupByInterval.week)
                        Text("Month").tag(InsightGroupByInterval.month)
                    }
                    .onChange(of: editorContent.groupBy) { _ in save() }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }

            let signalText = editorContent.signalType.isEmpty ? "All Signals" : editorContent.signalType
            let uniqueText = editorContent.uniqueUser ? ", unique" : ""

            CustomSection(header: Text("Signal Type"), summary: Text(signalText + uniqueText), footer: Text("What signal type are you interested in (e.g. appLaunchedRegularly)? Leave blank for any"), startCollapsed: true) {
                AutoCompletingTextField(
                    title: "All Signals",
                    text: $editorContent.signalType,
                    autocompletionOptions: signalTypeAutocompletionOptions,
                    onEditingChanged: { save() }
                )

                Toggle(isOn: $editorContent.uniqueUser) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Unique by User")
                            Text("Check to count each user only once")
                                .font(.footnote)
                                .foregroundColor(.grayColor)
                        }
                        Spacer()
                    }
                }
                .onChange(of: editorContent.uniqueUser) { _ in save() }
            }

            CustomSection(header: Text("Breakdown"), summary: Text(editorContent.breakdownKey.isEmpty ? "No Breakdown" : editorContent.breakdownKey), footer: Text("If you enter a key for the metadata payload here, you'll get a breakdown of its values."), startCollapsed: true) {
                AutoCompletingTextField(
                    title: "Payload Key",
                    text: $editorContent.breakdownKey,
                    autocompletionOptions: filterAutocompletionOptions,
                    onEditingChanged: { save() }
                )
            }

            CustomSection(header: Text("Filters"), summary: Text("\(editorContent.filters.count) filters"), footer: Text("To add a filter, type a key into the text field and tap 'Add'"), startCollapsed: true) {
                FilterEditView(keysAndValues: $editorContent.filters, autocompleteOptions: filterAutocompletionOptions)
                    .onChange(of: editorContent.filters) { _ in save() }
            }

            CustomSection(header: Text("Insight Group"), summary: Text(insightGroupTitle), footer: Text("All insights belong to an insight group."), startCollapsed: true) {
                Picker(selection: $editorContent.groupID, label: Text("Group")) {
                    ForEach(insightService.insightGroups(for: appID) ?? []) { insightGroup in
                        Text(insightGroup.title).tag(insightGroup.id)
                    }
                }
                .onChange(of: editorContent.groupID) { _ in save() }
                .pickerStyle(DefaultPickerStyle())
            }

            CustomSection(header: Text("Meta Information"), summary: EmptyView(), footer: EmptyView(), startCollapsed: true) {
                if let dto = insightCalculationService.insightData(for: editorContent.id, in: insightGroupID, in: appID),
                   let calculatedAt = dto.calculatedAt, let calculationDuration = dto.calculationDuration
                {
                    Group {
                        Text("This Insight was last updated ")
                            + Text(calculatedAt, style: .relative).bold()
                            + Text(" ago. The server needed ")
                            + Text("\(calculationDuration) seconds").bold()
                            + Text(" to calculate it.")
                    }
                    .opacity(0.4)
                    .padding(.vertical, 2)

                    Group {
                        Text("The Insight will automatically be updated once it's ")
                            + Text("5 Minutes").bold()
                            + Text(" old.")
                    }
                    .opacity(0.4)
                    .padding(.bottom, 4)
                }

                Button("Copy Insight ID") {
                    saveToClipBoard(editorContent.id.uuidString)
                }
                .buttonStyle(SmallSecondaryButtonStyle())
            }

            CustomSection(header: Text("Delete"), summary: EmptyView(), footer: EmptyView(), startCollapsed: true) {
                Button("Delete this Insight", action: {
                    showingAlert = true
                })
                    .buttonStyle(SmallSecondaryButtonStyle())
                    .accentColor(.red)
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Are you sure you want to delete the Insight \(insightCalculationService.insightData(for: editorContent.id, in: insightGroupID, in: appID)?.title ?? "–")?"),
                message: Text("This will delete the Insight. Your signals are not affected."),
                primaryButton: .destructive(Text("Delete")) {
                    insightService.delete(insightID: editorContent.id, in: insightGroupID, in: appID) { _ in
                        self.presentation.wrappedValue.dismiss()
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .navigationTitle("Edit Insight")
        .onAppear {
            updatePayloadKeys()
        }

        if insightCalculationService.insightData(for: editorContent.id, in: insightGroupID, in: appID) != nil {
            #if os(macOS)
                ScrollView {
                    form
                        .padding()
                        .toolbar {
                            ToolbarItemGroup {
                                Spacer()

                                Button(action: toggleRightSidebar) {
                                    Image(systemName: "sidebar.right")
                                        .help("Toggle Sidebar")
                                }
                                .help("Toggle the right sidebar")
                            }
                        }
                }
            #else
                VStack {
                    InsightView(topSelectedInsightID: .constant(nil), appID: appID, insightGroupID: insightGroupID, insightID: editorContent.id)
                        .frame(maxHeight: 200)

                    form
                }
            #endif
        }
    }
}
