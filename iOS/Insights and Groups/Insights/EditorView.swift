//
//  EditorView.swift
//  Telemetry Viewer (iOS)
//
//  Created by Martin Václavík on 29.12.2021.
//

import DataTransferObjects
import SwiftUI
import TelemetryClient
import WidgetKit

class EditorViewModel: ObservableObject {
    struct InsightType: PickerItem {
        var name: String
        var explanation: String
        var id: UUID
        
        static let timeSeries = InsightType(name: "Time Series", explanation: "A time series insight looks at discrete chunks of time and counts values in those times, for example 'Signal counts for each day'. These are awesome for displaying in line charts or bar charts.", id: UUID())
        static let breakdown = InsightType(name: "Breakdown", explanation: "A breakdown insights collects all signals, extracts a specific payload key from them, and then gives you a list of which possible values are inside the payload key, and how often they occurred. Ideal for seeing how many users use each version of your app for example, and well suited with donut charts.", id: UUID())
        static let customQuery = InsightType(name: "Custom Query", explanation: "Custom queries allow you to write your query in a JSON based language. We'll add filters for appID and your selected date range on the server. This is a very experimental early feature right now. Trust nothing. Trust no one. Everything you found out, you want to forget.", id: UUID())
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
        
        self.id = insight.id
        self.appID = appID
        self.groupID = insight.groupID
        self.order = insight.order ?? 0
        self.title = insight.title
        self.accentColor = insight.accentColor ?? ""
        self.displayMode = insight.displayMode
        self.signalType = insight.signalType ?? ""
        self.uniqueUser = insight.uniqueUser
        self.filters = insight.filters
        self.breakdownKey = insight.breakdownKey ?? ""
        self.groupBy = insight.groupBy ?? .day
        
        if insight.customQuery != nil {
            self.insightType = .customQuery
        } else if insight.breakdownKey != nil {
            self.insightType = .breakdown
        } else {
            self.insightType = .timeSeries
        }
        
        self.isSettingUp = false
        print("init: \(insight.title)")
    }
    
    static func string(from customQuery: CustomQuery?) -> String {
        guard let customQuery = customQuery else { return "" }
        
        let encoder = JSONEncoder.telemetryEncoder
        encoder.outputFormatting = .prettyPrinted
        
        guard let data = try? JSONEncoder.telemetryEncoder.encode(customQuery),
              let stringValue = String(data: data, encoding: .utf8)
        else {
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
            breakdownKey: insightType != .breakdown ? nil : breakdownKey,
            groupBy: groupBy,
            displayMode: displayMode,
            isExpanded: false,
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
            }
        }
        
        insightService.insightDictionary[id] = generatedInsight 
        
        WidgetCenter.shared.reloadAllTimelines()
        
        TelemetryManager.send("EditorViewSave")
    }
    
    let id: DTOv2.Insight.ID
    let appID: DTOv2.App.ID
    
    #warning("TODO: Save changes automatically? Or warn on dismiss?")
    
    @Published var order: Double
    
    @Published var title: String
    
    @Published var accentColor: String
    
    @Published var customQuery: CustomQuery?
    
    @Published var customQueryString: String
    
    @Published var insightType: InsightType
    
    /// How should this insight's data be displayed?
    @Published var displayMode: InsightDisplayMode
    
    /// Which signal types are we interested in? If empty, do not filter by signal type
    @Published var signalType: String
    
    /// If true, only include at the newest signal from each user
    @Published var uniqueUser: Bool
    
    /// Only include signals that match all of these key-values in the payload
    @Published var filters: [String: String]
    
    /// If set, break down the values in this key
    @Published var breakdownKey: String
    
    /// If set, group and count found signals by this time interval. Incompatible with breakdownKey
    @Published var groupBy: InsightGroupByInterval
    
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

extension InsightDisplayMode: PickerItem {
    var name: String {
        switch self {
        case .raw:
            return "Raw"
        case .barChart:
            return "Bar chart"
        case .lineChart:
            return "Line chart"
        case .pieChart:
            return "Pie chart"
        default:
            return "number.square"
        }
    }
    
    var explanation: String {
        chartTypeExplanationText
    }
    
    public var id: UUID {
        UUID()
    }
}

struct EditorView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var groupService: GroupService
    
    @StateObject var viewModel: EditorViewModel
    
    @State var showingAlert: Bool = false
    
    @Binding var selectedInsightID: UUID?
    
    var nameAndGroupSection: some View {
        Section(header: Text("General")) {
            TextField("Title e.g. 'Daily Active Users'", text: $viewModel.title)
            
            Picker(selection: $viewModel.groupID, label: Text("Group")) {
                ForEach(appService.app(withID: viewModel.appID)?.insightGroupIDs ?? [], id: \.self) { insightGroupID in
                    TinyLoadingStateIndicator(
                        loadingState: groupService.loadingState(for: insightGroupID),
                        title: groupService.group(withID: insightGroupID)?.title
                    )
                    .tag(insightGroupID)
                }
            }
            Picker(selection: $viewModel.accentColor, label: Text("Color")) {
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
    }
    
    var insightTypeSection: some View {
        Section(header: Text("Insight Configuration")) {
            DetailedPicker(title: "Chart Type",
                           summary: viewModel.displayMode.chartImage,
                           selectedItem: $viewModel.displayMode,
                           options: [
                               InsightDisplayMode.raw,
                               InsightDisplayMode.barChart,
                               InsightDisplayMode.lineChart,
                               InsightDisplayMode.pieChart
                           ])
            DetailedPicker(title: "Insight Type",
                           summary: Text(viewModel.insightType.name),
                           selectedItem: $viewModel.insightType,
                           options: [
                               EditorViewModel.InsightType.timeSeries,
                               EditorViewModel.InsightType.breakdown,
                               EditorViewModel.InsightType.customQuery
                           ])
            if viewModel.insightType == .timeSeries {
                GroupByPicker(title: "Group Values by",
                              selection: $viewModel.groupBy,
                              options: [
                                  InsightGroupByInterval.hour,
                                  InsightGroupByInterval.day,
                                  InsightGroupByInterval.week,
                                  InsightGroupByInterval.month
                              ],
                              description: "Group signals by time interval. The more fine-grained the grouping, the more separate values you'll receive.")
            }
        }
    }
    
    var groupBySection: some View {
        CustomSection(header: Text("Group Values by"), summary: Text(viewModel.groupBy.rawValue), footer: Text(""), startCollapsed: true) {
            Picker(selection: $viewModel.groupBy, label: Text("")) {
                Text("Hour").tag(InsightGroupByInterval.hour)
                Text("Day").tag(InsightGroupByInterval.day)
                Text("Week").tag(InsightGroupByInterval.week)
                Text("Month").tag(InsightGroupByInterval.month)
            }
            .pickerStyle(SegmentedPickerStyle())
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
        }
    }
    
    var signalTypeSection: some View {
        let signalText = viewModel.signalType.isEmpty ? "All Signals" : viewModel.signalType
        let uniqueText = viewModel.uniqueUser ? ", unique" : ""
        
        return CustomSection(header: Text("Signal Type"), summary: Text(signalText + uniqueText), footer: Text("If you want, only look at a single signal type for this insight."), startCollapsed: true) {
            Picker("Signal", selection: $viewModel.signalType) {
                Text("All Signals").tag("")
                
                ForEach(viewModel.signalTypeAutocompletionOptions, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            
            if viewModel.insightType == .breakdown {
                Picker("Breakdown by", selection: $viewModel.breakdownKey) {
                    Text("None").tag("")
                    
                    ForEach(viewModel.filterAutocompletionOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
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
    }
    
    var filtersSection: some View {
        CustomSection(header: Text("Filters"), summary: Text("\(viewModel.filters.count) filters"), footer: Text("Due to a server limitation, currently only one filter at a time is supported. This will change in the future."), startCollapsed: true) {
            FilterEditView(keysAndValues: $viewModel.filters, autocompleteOptions: viewModel.filterAutocompletionOptions)
        }
    }
    
    var metaSection: some View {
        Section(header: Text("Meta Information")) {
            Button("Copy Insight ID") {
                saveToClipBoard(viewModel.id.uuidString)
            }
        }
    }
    
    var deleteSection: some View {
        Section(header: Text("Delete")) {
            Button("Delete this Insight", role: .destructive, action: {
                showingAlert = true
            })
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("Are you sure you want to delete the Insight \(viewModel.title)?"),
                        message: Text("This will delete the Insight. Your signals are not affected."),
                        primaryButton: .destructive(Text("Delete")) {
                            viewModel.insightService.delete(insightID: viewModel.id) { _ in
                                groupService.retrieveGroup(with: viewModel.groupID)
                                selectedInsightID = nil
                                dismiss()
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
        }
    }
    
    var customQuerySection: some View {
        CustomSection(header: Text("Custom Query"), summary: EmptyView(), footer: EmptyView(), startCollapsed: true) {
            Text(viewModel.customQueryString)
                .lineLimit(nil)
                .font(.system(.footnote, design: .monospaced))
        }
    }
    
    var body: some View {
        Form {
            nameAndGroupSection
            
            insightTypeSection
            
            if [.timeSeries, .breakdown].contains(viewModel.insightType) {
                signalTypeSection
                
                filtersSection
                
            } else if viewModel.insightType == .customQuery {
                customQuerySection
            }
            
            metaSection
            
            deleteSection
        }
        .onAppear {
            TelemetryManager.send("EditorViewAppear")
            
            viewModel.lexiconService.getPayloadKeys(for: viewModel.appID)
            viewModel.lexiconService.getSignalTypes(for: viewModel.appID)
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Save", action: viewModel.save)
            }
        }
    }
}

struct EditorView_Previews: PreviewProvider {
    static var apiClientPreview = APIClient()
    static var previews: some View {
        NavigationView {
            EditorView(viewModel: EditorViewModel(insight: MockData.exampleInsightVersion2,
                                                  appID: MockData.app1.id,
                                                  insightService: InsightService(api: apiClientPreview,
                                                                                 cache: CacheLayer(),
                                                                                 errors: ErrorService()),
                                                  groupService: GroupService(api: apiClientPreview,
                                                                             cache: CacheLayer(),
                                                                             errors: ErrorService()),
                                                  lexiconService: LexiconService(api: APIClient())),
                       selectedInsightID: .constant(MockData.exampleInsightVersion2.id))
                .environmentObject(AppService(api: apiClientPreview, cache: CacheLayer(), errors: ErrorService()))
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
