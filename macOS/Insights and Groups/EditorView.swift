//
//  EditorView.swift
//  EditorView
//
//  Created by Daniel Jilg on 23.08.21.
//

import SwiftUI
import TelemetryClient
import DataTransferObjects

class EditorViewModel: ObservableObject {
    enum InsightType {
        case timeSeries
        case breakdown
        case customQuery
        
        var stringValue: String {
            switch self {
            case .timeSeries:
                return "Time Series"
            case .breakdown:
                return "Breakdown"
            case .customQuery:
                return "Custom Query"
            }
        }
        
        var explanation: String {
            switch self {
            case .timeSeries:
                return "A time series insight looks at discrete chunks of time and counts values in those times, for example 'Signal counts for each day'. These are awesome for displaying in line charts or bar charts."
            case .breakdown:
                return "A breakdown insights collects all signals, extracts a specific payload key from them, and then gives you a list of which possible values are inside the payload key, and how often they occurred. Ideal for seeing how many users use each version of your app for example, and well suited with donut charts."
            case .customQuery:
                return "Custom queries allow you to write your query in a JSON based language. We'll add filters for appID and your selected date range on the server. This is a very experimental early feature right now. Trust nothing. Trust no one. Everything you found out, you want to forget."
            }
        }
    }
    
    let groupService: GroupService
    let insightService: InsightService
    let lexiconService: LexiconService
    
    init(insight: DTOv2.Insight, appID: UUID, insightService: InsightService, groupService: GroupService, lexiconService: LexiconService) {
        self.groupService = groupService
        self.insightService = insightService
        self.lexiconService = lexiconService
        
        self.customQueryString = Self.string(from: insight.customQuery)
        self.customQuery = insight.customQuery
        if insight.customQuery != nil {
            self.insightType = .customQuery
        } else if insight.breakdownKey != nil {
            self.insightType = .breakdown
        } else {
            self.insightType = .timeSeries
        }
        
        self.id = insight.id
        self.appID = appID
        self.groupID = insight.groupID
        self.order = insight.order ?? 0
        self.title = insight.title
        self.accentColor = insight.accentColor ?? ""
        self.displayMode = insight.displayMode
        self.isExpanded = insight.isExpanded
        self.signalType = insight.signalType ?? ""
        self.uniqueUser = insight.uniqueUser
        self.filters = insight.filters
        self.breakdownKey = insight.breakdownKey ?? ""
        self.groupBy = insight.groupBy ?? .day
        
        self.isSettingUp = false
    }
    
    static func string(from customQuery: CustomQuery?) -> String {
        guard let customQuery = customQuery else { return "" }
        
        let encoder = JSONEncoder.telemetryEncoder
        encoder.outputFormatting = .prettyPrinted
        
        guard let data = try? JSONEncoder.telemetryEncoder.encode(customQuery),
              let stringValue  = String(data: data, encoding: .utf8) else {
                  return ""
              }
        
        encoder.outputFormatting = .sortedKeys
        
        return stringValue
    }
    
    var generatedInsight: DTOv2.Insight {
        DTOv2.Insight(
            id: id,
            groupID: groupID,
            order: order,
            title: title,
            accentColor: accentColor != "" ? accentColor : nil,
            signalType: signalType.isEmpty ? nil : signalType,
            uniqueUser: uniqueUser,
            filters: filters,
            breakdownKey: breakdownKey.isEmpty ? nil : breakdownKey,
            groupBy: groupBy,
            displayMode: displayMode,
            isExpanded: isExpanded,
            lastRunTime: nil,
            lastRunAt: nil
        )
    }
    
    private var lastSaveCallAt = Date.distantPast
    private let waitBeforeSave: TimeInterval = 1
    private var isSettingUp = false
    private var oldGroupID: UUID?
    
    func save() {
        insightService.update(
            insightID: id,
            in: groupID,
            in: appID,
            with: generatedInsight
        ) { _ in
            if let oldGroupID = self.oldGroupID {
                let newGroupID = self.groupID
                
                self.oldGroupID = nil
                
                self.groupService.retrieveGroup(with: oldGroupID)
                self.groupService.retrieveGroup(with: newGroupID)
                
                self.needsSaving = false
            }
        }
        
        TelemetryManager.send("EditorViewSave")
    }
    
    func setNeedsSaving(_ newValue: Bool) {
        withAnimation {
            needsSaving = newValue
        }
    }
    
    let id: DTOv2.Insight.ID
    let appID: DTOv2.App.ID
    
    @Published var needsSaving: Bool = false
    
    @Published var order: Double { didSet { save() }}
    
    @Published var title: String { didSet { setNeedsSaving(true) }}
    
    @Published var accentColor: String { didSet { save() }}
    
    @Published var customQuery: CustomQuery?
    
    @Published var customQueryString: String
    
    @Published var insightType: InsightType
    
    /// How should this insight's data be displayed?
    @Published var displayMode: InsightDisplayMode { didSet { save() }}
    
    /// If true, the insight will be displayed bigger
    @Published var isExpanded: Bool { didSet { setNeedsSaving(true) }}
    
    /// Which signal types are we interested in? If empty, do not filter by signal type
    @Published var signalType: String { didSet { save() }}

    /// If true, only include at the newest signal from each user
    @Published var uniqueUser: Bool { didSet { save() }}

    /// Only include signals that match all of these key-values in the payload
    @Published var filters: [String: String] { didSet { setNeedsSaving(true) }}

    /// If set, break down the values in this key
    @Published var breakdownKey: String { didSet { save() }}

    /// If set, group and count found signals by this time interval. Incompatible with breakdownKey
    @Published var groupBy: InsightGroupByInterval { didSet { save() }}

    /// Which group should the insight belong to? (Only use this in update mode)
    @Published var groupID: UUID {
        didSet {
            oldGroupID = oldValue
            save()
        }
    }
    
    var filterAutocompletionOptions: [String] {
        return lexiconService.payloadKeys(for: appID).map(\.name).sorted(by: { $0.lowercased() < $1.lowercased() })
    }

    var signalTypeAutocompletionOptions: [String] {
        return lexiconService.signalTypes(for: appID).map(\.type).sorted(by: { $0.lowercased() < $1.lowercased() })
    }
}

struct EditorView: View {
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var groupService: GroupService
    
    @ObservedObject var viewModel: EditorViewModel
    
    @State var showingAlert: Bool = false
    
    @Binding var selectedInsightID: UUID?
    
    var nameAndGroupSection: some View {
        CustomSection(header: Text("Name and Group"), summary: Text(viewModel.title), footer: Text("The Title of This Insight, and in which group it is located"), startCollapsed: true) {
            TextField("Title e.g. 'Daily Active Users'", text: $viewModel.title)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Toggle(isOn: $viewModel.isExpanded, label: {
                Text("Show Expanded")
            })
                
            Picker(selection: $viewModel.groupID, label: Text("Group")) {
                ForEach(appService.app(withID: viewModel.appID)?.insightGroupIDs ?? [], id: \.self) { insightGroupID in
                    TinyLoadingStateIndicator(
                        loadingState: groupService.loadingState(for: insightGroupID),
                        title: groupService.group(withID: insightGroupID)?.title
                    )
                    .tag(insightGroupID)
                }
            }
            .pickerStyle(DefaultPickerStyle())
        }
        .padding(.top)
        .padding(.horizontal)
    }
        
    var chartTypeSection: some View {
        CustomSection(header: Text("Chart Type"), summary: viewModel.displayMode.chartImage, footer: Text(viewModel.displayMode.chartTypeExplanationText), startCollapsed: true) {
            Picker(selection: $viewModel.displayMode, label: Text("")) {
                Image(systemName: "list.dash.header.rectangle").tag(InsightDisplayMode.raw)
                Image(systemName: "chart.bar.fill").tag(InsightDisplayMode.barChart)
                Image(systemName: "chart.xyaxis.line").tag(InsightDisplayMode.lineChart)
                Image(systemName: "chart.pie.fill").tag(InsightDisplayMode.pieChart)
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding(.horizontal)
    }
    
    var insightTypeSection: some View {
        CustomSection(header: Text("Insight Type"), summary: Text(viewModel.insightType.stringValue), footer: Text(viewModel.insightType.explanation), startCollapsed: true) {
            Picker(selection: $viewModel.insightType, label: Text("")) {
                Text(EditorViewModel.InsightType.timeSeries.stringValue).tag(EditorViewModel.InsightType.timeSeries)
                Text(EditorViewModel.InsightType.breakdown.stringValue).tag(EditorViewModel.InsightType.breakdown)
                Text(EditorViewModel.InsightType.customQuery.stringValue).tag(EditorViewModel.InsightType.customQuery)
            }
        }
        .padding(.horizontal)
    }
    
    var groupBySection: some View {
        CustomSection(header: Text("Group Values by"), summary: Text(viewModel.groupBy.rawValue), footer: Text("Group signals by time interval. The more fine-grained the grouping, the more separate values you'll receive."), startCollapsed: true) {
            Picker(selection: $viewModel.groupBy, label: Text("")) {
                Text("Hour").tag(InsightGroupByInterval.hour)
                Text("Day").tag(InsightGroupByInterval.day)
                Text("Week").tag(InsightGroupByInterval.week)
                Text("Month").tag(InsightGroupByInterval.month)
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding(.horizontal)
    }
    
    var signalTypeSection: some View {
        let signalText = viewModel.signalType.isEmpty ? "All Signals" : viewModel.signalType
        let uniqueText = viewModel.uniqueUser ? ", unique" : ""

        return CustomSection(header: Text("Signal Type"), summary: Text(signalText + uniqueText), footer: Text("If you want, only look at a single signal type for this insight."), startCollapsed: true) {
            Picker("Signal Type", selection: $viewModel.signalType) {
                Text("All Signals").tag("")
                
                ForEach(viewModel.signalTypeAutocompletionOptions, id: \.self) { option in
                    Text(option).tag(option)
                }
            }

            Toggle(isOn: $viewModel.uniqueUser) {
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
        .padding(.horizontal)
    }
    
    var filtersSection: some View {
        CustomSection(header: Text("Filters"), summary: Text("\(viewModel.filters.count) filters"), footer: Text("Due to a server limitation, currently only one filter at a time is supported. This will change in the future."), startCollapsed: true) {
            FilterEditView(keysAndValues: $viewModel.filters, autocompleteOptions: viewModel.filterAutocompletionOptions)
        }
        .padding(.horizontal)
    }
    
    var breakdownSection: some View {
        CustomSection(header: Text("Breakdown"), summary: Text(viewModel.breakdownKey.isEmpty ? "No Breakdown" : viewModel.breakdownKey), footer: Text("Select a metadata payload key, you'll get a breakdown of its values."), startCollapsed: true) {
            Picker("Key", selection: $viewModel.breakdownKey) {
                Text("None").tag("")
                
                ForEach(viewModel.filterAutocompletionOptions, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
        }
        .padding(.horizontal)
    }
    
    var metaSection: some View {
        CustomSection(header: Text("Meta Information"), summary: EmptyView(), footer: EmptyView(), startCollapsed: true) {
            Button("Copy Insight ID") {
                saveToClipBoard(viewModel.id.uuidString)
            }
            .buttonStyle(SmallSecondaryButtonStyle())
        }
        .padding(.horizontal)
    }
    
    var deleteSection: some View {
        CustomSection(header: Text("Delete"), summary: EmptyView(), footer: EmptyView(), startCollapsed: true) {
            Button("Delete this Insight", action: {
                showingAlert = true
            })
                .buttonStyle(SmallSecondaryButtonStyle())
                .accentColor(.red)
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("Are you sure you want to delete the Insight \(viewModel.title)?"),
                        message: Text("This will delete the Insight. Your signals are not affected."),
                        primaryButton: .destructive(Text("Delete")) {
                            viewModel.insightService.delete(insightID: viewModel.id) { _ in
                                groupService.retrieveGroup(with: viewModel.groupID)
                                selectedInsightID = nil
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
        }
        .padding(.horizontal)
    }
    
    var customQuerySection: some View {
        CustomSection(header: Text("Custom Query"), summary: EmptyView(), footer: EmptyView(), startCollapsed: true) {
            Text(viewModel.customQueryString)
                .lineLimit(nil)
                .font(.system(.footnote, design: .monospaced))
        }
        .padding(.horizontal)
    }
    
    var colorSelectionSection: some View {
        CustomSection(header: Text("Accent Color"), summary: Text(viewModel.accentColor), footer: Text("If you want, you can set a custom color for this insight"), startCollapsed: true) {
            Picker(selection: $viewModel.accentColor, label: Text("")) {
                Text("Default Telemetry Orange").tag("")
                Text("Aioli").tag("69D2E7")
                Text("Panda Water").tag("A7DBD8")
                Text("Grandma's Pants").tag("E0E4CC")
                Text("Giant Goldfish").tag("F38630")
                Text("Post Office").tag("FDBD33")
                Text("Urgent!").tag("EB2727")
                Text("Schmandalf").tag("C2CBCE")
                Text("Inked").tag("2A363B")
                Text("Not Sitting Straight").tag("E0A4C3")
            }
        }
        .padding(.horizontal)
    }

    var formContent: some View {
        Group {
            nameAndGroupSection
            
            colorSelectionSection

            chartTypeSection

            insightTypeSection
            
            if [.timeSeries, .breakdown].contains(viewModel.insightType) {
                if viewModel.insightType == .timeSeries {
                    groupBySection
                }
            
                signalTypeSection

                filtersSection
            
                if viewModel.insightType == .breakdown {
                    breakdownSection
                }
            } else if viewModel.insightType == .customQuery {
                customQuerySection
            }
            
            metaSection

            deleteSection
            
            if viewModel.needsSaving {
                Button(action: viewModel.save) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                }
                .keyboardShortcut(.defaultAction)
                .padding(.horizontal)
            }
        }
        .onAppear {
            TelemetryManager.send("EditorViewAppear")
            
            viewModel.lexiconService.getPayloadKeys(for: viewModel.appID)
            viewModel.lexiconService.getSignalTypes(for: viewModel.appID)
        }
        .onDisappear {
            viewModel.save()
        }
    }
    
    var body: some View {
        ScrollView {
            formContent
        }
    }
}
