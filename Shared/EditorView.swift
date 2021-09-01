//
//  EditorView.swift
//  EditorView
//
//  Created by Daniel Jilg on 23.08.21.
//

import SwiftUI

class EditorViewModel: ObservableObject {
    enum InsightType {
        case timeSeries
        case breakdown
        
        var stringValue: String {
            switch self {
            case .timeSeries:
                return "Time Series"
            case .breakdown:
                return "Breakdown"
            }
        }
        
        var explanation: String {
            switch self {
            case .timeSeries:
                return "A time series insight looks at discrete chunks of time and counts values in those times, for example 'Signal counts for each day'. These are awesome for displaying in line charts or bar charts."
            case .breakdown:
                return "A breakdown insights collects all signals, extracts a specific payload key from them, and then gives you a list of which possible values are inside the payload key, and how often they occurred. Ideal for seeing how many users use each version of your app for example, and well suited with donut charts."
            }
        }
    }
    
    let insightService: InsightService
    let lexiconService: LexiconService
    
    init(insight: DTOsWithIdentifiers.Insight, appID: UUID, insightService: InsightService, lexiconService: LexiconService) {
        self.insightService = insightService
        self.lexiconService = lexiconService
        
        self.insightType = insight.breakdownKey != nil ? .breakdown : .timeSeries
        
        self.id = insight.id
        self.appID = appID
        self.groupID = insight.groupID
        self.order = insight.order ?? 0
        self.title = insight.title
        self.displayMode = insight.displayMode
        self.isExpanded = insight.isExpanded
        self.signalType = insight.signalType ?? ""
        self.uniqueUser = insight.uniqueUser
        self.filters = insight.filters
        self.breakdownKey = insight.breakdownKey ?? ""
        self.groupBy = insight.groupBy ?? .day
        
        self.isSettingUp = false
    }
    
    var generatedInsight: DTOsWithIdentifiers.Insight {
        DTOsWithIdentifiers.Insight(
            id: id,
            groupID: groupID,
            order: order,
            title: title,
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
    
    func shouldSave() {
        guard !isSettingUp else { return }
        
        lastSaveCallAt = Date()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + waitBeforeSave + 0.01) {
            if -self.lastSaveCallAt.timeIntervalSinceNow > self.waitBeforeSave {
                self.save()
            }
        }
    }
    
    func save() {
        insightService.update(
            insightID: id,
            in: groupID,
            in: appID,
            with: generatedInsight
        ) { _ in
        }
    }
    
    let id: DTOsWithIdentifiers.Insight.ID
    let appID: DTOsWithIdentifiers.App.ID
    
    @Published var order: Double { didSet { shouldSave() }}
    
    @Published var title: String { didSet { shouldSave() }}
    
    @Published var insightType: InsightType
    
    /// How should this insight's data be displayed?
    @Published var displayMode: InsightDisplayMode { didSet { shouldSave() }}
    
    /// If true, the insight will be displayed bigger
    @Published var isExpanded: Bool { didSet { shouldSave() }}
    
    /// Which signal types are we interested in? If empty, do not filter by signal type
    @Published var signalType: String { didSet { shouldSave() }}

    /// If true, only include at the newest signal from each user
    @Published var uniqueUser: Bool { didSet { shouldSave() }}

    /// Only include signals that match all of these key-values in the payload
    @Published var filters: [String: String] { didSet { shouldSave() }}

    /// If set, break down the values in this key
    @Published var breakdownKey: String { didSet { shouldSave() }}

    /// If set, group and count found signals by this time interval. Incompatible with breakdownKey
    @Published var groupBy: InsightGroupByInterval { didSet { shouldSave() }}

    /// Which group should the insight belong to? (Only use this in update mode)
    @Published var groupID: UUID { didSet { shouldSave() }}
    
    var filterAutocompletionOptions: [String] {
        return lexiconService.payloadKeys(for: appID).filter { !$0.isHidden }.map(\.payloadKey)
    }

    var signalTypeAutocompletionOptions: [String] {
        return lexiconService.signalTypes(for: appID).map(\.type)
    }
}

extension InsightDisplayMode {
    var chartTypeExplanationText: String {
        switch self {
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
        switch self {
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
}

struct EditorView: View {
    @EnvironmentObject var groupService: GroupService
    
    @ObservedObject var viewModel: EditorViewModel
    
    @State var showingAlert: Bool = false
    
    var body: some View {
        ScrollView {
            CustomSection(header: Text("Name"), summary: Text(viewModel.title), footer: Text("The Title of This Insight")) {
                TextField("Title e.g. 'Daily Active Users'", text: $viewModel.title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                #if os(macOS)
                Toggle(isOn: $viewModel.isExpanded, label: {
                    Text("Show Expanded")
                })
                #endif
            }
            .padding(.top)
            .padding(.horizontal)

            CustomSection(header: Text("Chart Type"), summary: viewModel.displayMode.chartImage, footer: Text(viewModel.displayMode.chartTypeExplanationText), startCollapsed: true) {
                Picker(selection: $viewModel.displayMode, label: Text("")) {
                    Image(systemName: "number.square.fill").tag(InsightDisplayMode.raw)
                    Image(systemName: "chart.bar.fill").tag(InsightDisplayMode.barChart)
                    Image(systemName: "squares.below.rectangle").tag(InsightDisplayMode.lineChart)
                    Image(systemName: "chart.pie.fill").tag(InsightDisplayMode.pieChart)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding(.horizontal)
            
            CustomSection(header: Text("Insight Type"), summary: Text(viewModel.insightType.stringValue), footer: Text(viewModel.insightType.explanation)) {
                Picker(selection: $viewModel.insightType, label: Text("")) {
                    Text(EditorViewModel.InsightType.timeSeries.stringValue).tag(EditorViewModel.InsightType.timeSeries)
                    Text(EditorViewModel.InsightType.breakdown.stringValue).tag(EditorViewModel.InsightType.breakdown)
                }
            }
            .padding(.horizontal)
            
            if viewModel.insightType == .timeSeries {
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
            
            let signalText = viewModel.signalType.isEmpty ? "All Signals" : viewModel.signalType
            let uniqueText = viewModel.uniqueUser ? ", unique" : ""

            CustomSection(header: Text("Signal Type"), summary: Text(signalText + uniqueText), footer: Text("What signal type are you interested in (e.g. appLaunchedRegularly)? Leave blank for any"), startCollapsed: true) {
                AutoCompletingTextField(
                    title: "All Signals",
                    text: $viewModel.signalType,
                    autocompletionOptions: viewModel.signalTypeAutocompletionOptions
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())

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

            CustomSection(header: Text("Filters"), summary: Text("\(viewModel.filters.count) filters"), footer: Text("To add a filter, type a key into the text field and tap 'Add'"), startCollapsed: true) {
                FilterEditView(keysAndValues: $viewModel.filters, autocompleteOptions: viewModel.filterAutocompletionOptions)
            }
            .padding(.horizontal)
            
            if viewModel.insightType == .breakdown {
                CustomSection(header: Text("Breakdown"), summary: Text(viewModel.breakdownKey.isEmpty ? "No Breakdown" : viewModel.breakdownKey), footer: Text("If you enter a key for the metadata payload here, you'll get a breakdown of its values."), startCollapsed: true) {
                    AutoCompletingTextField(
                        title: "Payload Key",
                        text: $viewModel.breakdownKey,
                        autocompletionOptions: viewModel.filterAutocompletionOptions
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
            }
            
            CustomSection(header: Text("Meta Information"), summary: EmptyView(), footer: EmptyView(), startCollapsed: true) {
                Button("Copy Insight ID") {
                    saveToClipBoard(viewModel.id.uuidString)
                }
                .buttonStyle(SmallSecondaryButtonStyle())
            }
            .padding(.horizontal)

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
                                viewModel.insightService.delete(insightID: viewModel.id, in: viewModel.groupID, in: viewModel.appID) { _ in
                                    // TODO: Ios ONLY: self.presentation.wrappedValue.dismiss()
                                    groupService.retrieveGroup(with: viewModel.groupID)
                                }
                            },
                            secondaryButton: .cancel()
                        )
                    }
            }
            .padding(.horizontal)
        }
    }
}
