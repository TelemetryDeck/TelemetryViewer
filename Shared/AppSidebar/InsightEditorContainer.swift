//
//  InsightEditor.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 26.11.20.
//

import SwiftUI



class InsightEditorContainerViewModel: ObservableObject {
    let appID: UUID
    @Binding var selectedInsightGroupID: UUID
    var selectedInsightID: Binding<UUID?>? = nil
    @ObservedObject var api: APIRepresentative

    var subModel: InsightEditorViewModel?

    init(api: APIRepresentative, appID: UUID, selectedInsightGroupID: Binding<UUID>, selectedInsightID: Binding<UUID?>) {
        self.appID = appID
        self._selectedInsightGroupID = selectedInsightGroupID
        self.api = api

        self.selectedInsightID = Binding(get: {
            selectedInsightID.wrappedValue
        }, set: { newValue in
            selectedInsightID.wrappedValue = newValue
            self.updateStateWithInsight()
        })
        self.updateStateWithInsight()
    }

    func updateStateWithInsight() {
        // The insightID has changed, generate a new sub model
        if let selectedInsightID = selectedInsightID?.wrappedValue {
            subModel = InsightEditorViewModel(
                api: api,
                appID: appID,
                selectedInsightGroupID: selectedInsightGroupID,
                selectedInsightID: selectedInsightID
            )
        } else {
            subModel = nil
        }
    }}

struct InsightEditorContainer: View {
    @ObservedObject var viewModel: InsightEditorContainerViewModel

    init(viewModel: InsightEditorContainerViewModel) {
        self.viewModel = viewModel
    }


    // Body
    var body: some View {
        if viewModel.subModel != nil {
            InsightEditor(viewModel: viewModel.subModel!)
        } else {
            Text("No Insight Selected").foregroundColor(.grayColor)
        }
    }
}

class InsightEditorViewModel: ObservableObject {
    @ObservedObject var api: APIRepresentative
    let appID: UUID
    let selectedInsightGroupID: UUID
    let selectedInsightID: UUID

    var saveTimer: Timer = Timer()

    @Published var insightOrder: Double = -1 { didSet { saveInsight() }}
    @Published var insightTitle: String = "" { didSet { saveInsight() }}
    @Published var insightSubtitle: String = "" { didSet { saveInsight() }}
    @Published var selectedInsightGroupIndex: Int = 0 { didSet { saveInsight() }}
    @Published var insightSignalType: String = "" { didSet { saveInsight() }}
    @Published var insightUniqueUser: Bool = false { didSet { saveInsight() }}
    @Published var insightFilters: [String: String] = [:] { didSet { saveInsight() }}
    @Published var insightRollingWindowSize: TimeInterval = -2592000
    @Published var insightBreakdownKey: String = "" { didSet { saveInsight() }}
    @Published var insightGroupBy: InsightGroupByInterval = .day { didSet { saveInsight() }}
    @Published var insightDisplayMode: InsightDisplayMode = .lineChart { didSet { saveInsight() }}
    @Published var insightIsExpanded: Bool = false { didSet { saveInsight() }}

    private var isSettingUp: Bool = false

    init(api: APIRepresentative, appID: UUID, selectedInsightGroupID: UUID, selectedInsightID: UUID) {
        self.api = api
        self.appID = appID
        self.selectedInsightGroupID = selectedInsightGroupID
        self.selectedInsightID  = selectedInsightID

        self.updateStateWithInsight()
    }

    // Derived Properties
    var app: TelemetryApp? {
        api.apps.first(where: { $0.id == appID })
    }

    var insightGroup: InsightGroup? {
        guard let app = app else { return nil }
        let insightGroup = api.insightGroups[app]?.first(where: { $0.id == selectedInsightGroupID })
        return insightGroup
    }

    var insight: Insight? {
        insightGroup?.insights.first { $0.id == selectedInsightID }
    }

    var insightDTO: InsightDataTransferObject? {
        return api.insightData[selectedInsightID]
    }

    var allInsightGroups: [InsightGroup] {
        if let app = app {
            return api.insightGroups[app] ?? []
        }

        return []
    }

    var filterAutocompletionOptions: [String] {
        guard let app = app else { return [] }
        return api.lexiconPayloadKeys[app, default: []].filter { !$0.isHidden }.map { $0.payloadKey }
    }

    var signalTypeAutocompletionOptions: [String] {
        guard let app = app else { return [] }
        return api.lexiconSignalTypes[app, default: []].map { $0.type }
    }

    var chartTypeExplanationText: String {
        switch insightDisplayMode {
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

    // Updating Functions
    func updateStateWithInsight() {
        self.isSettingUp = true

        self.insightOrder = insight?.order ?? -1
        self.insightTitle = insight?.title ?? ""
        self.insightSubtitle = insight?.subtitle ?? ""
        self.insightSignalType = insight?.signalType ?? ""
        self.insightUniqueUser = insight?.uniqueUser ?? false
        self.insightFilters = insight?.filters ?? [:]
        self.insightRollingWindowSize = insight?.rollingWindowSize ?? -2592000
        self.insightBreakdownKey = insight?.breakdownKey ?? ""
        self.insightGroupBy = insight?.groupBy ?? .day
        self.insightDisplayMode = insight?.displayMode ?? .lineChart
        self.insightIsExpanded = insight?.isExpanded ?? false
        self.selectedInsightGroupIndex = self.allInsightGroups.firstIndex { $0.id == selectedInsightGroupID } ?? 0

        self.isSettingUp = false
    }

    func saveInsight() {
        guard !isSettingUp else { return }

        saveTimer.invalidate()
        saveTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            self.delayedSaveInsight()
        }
    }

    private func delayedSaveInsight() {
        let insightDRB = InsightDefinitionRequestBody(
            order: insightOrder == -1 ? nil : insightOrder,
            title: insightTitle,
            subtitle: insightSubtitle.isEmpty ? nil : insightSubtitle,
            signalType: insightSignalType.isEmpty ? nil : insightSignalType,
            uniqueUser: insightUniqueUser,
            filters: insightFilters,
            rollingWindowSize: insightRollingWindowSize,
            breakdownKey: insightBreakdownKey.isEmpty ? nil : insightBreakdownKey,
            groupBy: insightGroupBy,
            displayMode: insightDisplayMode,
            groupID: allInsightGroups[selectedInsightGroupIndex].id,
            id: selectedInsightID,
            isExpanded: insightIsExpanded)

        if let insight = insight, let insightGroup = insightGroup, let app = app {
            api.update(insight: insight, in: insightGroup, in: app, with: insightDRB)
        }
    }

    func updateInsight() {
        if let insight = insight, let insightGroup = insightGroup, let app = app {
            api.getInsightData(for: insight, in: insightGroup, in: app)
        }
    }

    func deleteInsight() {
        if let insight = insight, let insightGroup = insightGroup, let app = app {
            api.delete(insight: insight, in: insightGroup, in: app)
        }
    }

    func updatePayloadKeys() {
        if let app = app {
            api.getPayloadKeys(for: app)
            api.getSignalTypes(for: app)
        }
    }

}

struct InsightEditor: View {
    @ObservedObject var viewModel: InsightEditorViewModel

    var padding: CGFloat? {
        #if os(macOS)
        return nil
        #else
        return 0
        #endif
    }

    var body: some View {
        let form = Form {
            CustomSection(header: Text("Title and Subtitle"), summary: EmptyView(), footer: Text("Give your insight a title, and optionally, add a longer descriptive subtitle for your insight.")) {
                TextField("Title e.g. 'Daily Active Users'", text: $viewModel.insightTitle)
                TextField("Optional Subtitle", text: $viewModel.insightSubtitle)

                Toggle(isOn: $viewModel.insightIsExpanded, label: {
                    Text("Show Expanded")
                })
            }

            let chartImage: Image = {
                switch viewModel.insightDisplayMode {
                case .raw:
                    return Image(systemName: "number.square.fill")
                case .barChart:
                    return Image(systemName: "chart.bar.fill")
                case .lineChart:
                    return Image(systemName: "squares.below.rectangle")
                case .pieChart:
                    return Image(systemName: "chart.pie.fill")
                default:
                    return Image("omsn")
                }
            }()

            CustomSection(header: Text("Chart Type"), summary: chartImage, footer: Text(viewModel.chartTypeExplanationText), startCollapsed: true) {
                Picker(selection: $viewModel.insightDisplayMode, label: Text("")) {
                    Image(systemName: "number.square.fill").tag(InsightDisplayMode.raw)
                    Image(systemName: "chart.bar.fill").tag(InsightDisplayMode.barChart)
                    Image(systemName: "squares.below.rectangle").tag(InsightDisplayMode.lineChart)
                    Image(systemName: "chart.pie.fill").tag(InsightDisplayMode.pieChart)
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            CustomSection(header: Text("Group Values by"), summary: Text(viewModel.insightGroupBy.rawValue), footer: Text("Group signals by time interval. The more fine-grained the grouping, the more separate valeus you'll receive."), startCollapsed: true) {
                Picker(selection: $viewModel.insightGroupBy, label: Text("")) {
                    Text("Hour").tag(InsightGroupByInterval.hour)
                    Text("Day").tag(InsightGroupByInterval.day)
                    Text("Week").tag(InsightGroupByInterval.week)
                    Text("Month").tag(InsightGroupByInterval.month)
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            let signalText = viewModel.insightSignalType.isEmpty ? "All Signals" : viewModel.insightSignalType
            let uniqueText = viewModel.insightUniqueUser ? ", unique" : ""

            CustomSection(header: Text("Signal Type"), summary: Text(signalText + uniqueText), footer: Text(("What signal type are you interested in (e.g. appLaunchedRegularly)? Leave blank for any")), startCollapsed: true) {
                AutoCompletingTextField(
                    title: "All Signals",
                    text: $viewModel.insightSignalType,
                    autocompletionOptions: viewModel.signalTypeAutocompletionOptions,
                    onEditingChanged: { viewModel.saveInsight() })

                Toggle(isOn: $viewModel.insightUniqueUser) {
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
            }

            CustomSection(header: Text("Breakdown"), summary: Text(viewModel.insightBreakdownKey.isEmpty ? "No Breakdown" : viewModel.insightBreakdownKey), footer: Text("If you enter a key for the metadata payload here, you'll get a breakdown of its values."), startCollapsed: true) {
                AutoCompletingTextField(
                    title: "Payload Key",
                    text: $viewModel.insightBreakdownKey,
                    autocompletionOptions: viewModel.filterAutocompletionOptions,
                    onEditingChanged: { viewModel.saveInsight() })

            }

            CustomSection(header: Text("Filters"), summary: Text("\(viewModel.insightFilters.count) filters"), footer: Text("To add a filter, type a key into the text field and tap 'Add'"), startCollapsed: true) {
                FilterEditView(keysAndValues: $viewModel.insightFilters, autocompleteOptions: viewModel.filterAutocompletionOptions)
            }

            CustomSection(header: Text("Insight Group"), summary: Text(viewModel.insightGroup?.title ?? "..."), footer: Text("All insights belong to an insight group."), startCollapsed: true) {
                Picker(selection: $viewModel.selectedInsightGroupIndex, label: EmptyView()) {
                    ForEach(0 ..< viewModel.allInsightGroups.count) {
                        Text(viewModel.allInsightGroups[$0].title)
                    }
                }
                .pickerStyle(DefaultPickerStyle())
            }

            if let dto = viewModel.insightDTO {
                CustomSection(header: Text("Last Updated"), summary: Text(dto.calculatedAt, style: .relative) + Text(" ago"), footer: EmptyView(), startCollapsed: true) {
                    Button("Update Now", action: viewModel.updateInsight)
                        .buttonStyle(SmallSecondaryButtonStyle())

                }
            }

            CustomSection(header: Text("Delete"), summary: EmptyView(), footer: EmptyView(), startCollapsed: true) {
                Button("Delete this Insight", action: viewModel.deleteInsight)
                    .buttonStyle(SmallSecondaryButtonStyle())
                    .accentColor(.red)
            }
        }
        .padding(.horizontal, padding)
        .onAppear() {
            viewModel.updatePayloadKeys()
        }

        #if os(macOS)
        ScrollView {
            form
        }
        #else
        form
        #endif
    }
}
