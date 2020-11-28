//
//  InsightEditor.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 26.11.20.
//

import SwiftUI

class InsightEditorViewModel: ObservableObject {
    let appID: UUID
    @Binding var selectedInsightGroupID: UUID
    var selectedInsightID: Binding<UUID?>? = nil
    @ObservedObject var api: APIRepresentative

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

    @Published var insightOrder: Double = -1
    @Published var insightTitle: String = ""
    @Published var insightSubtitle: String = ""
    @Published var selectedInsightGroupIndex: Int = 0
    @Published var insightSignalType: String = ""
    @Published var insightUniqueUser: Bool = false
    @Published var insightFilters: [String: String] = [:]
    @Published var insightRollingWindowSize: TimeInterval = -2592000
    @Published var insightBreakdownKey: String = ""
    @Published var insightDisplayMode: InsightDisplayMode = .lineChart
    @Published var insightIsExpanded: Bool = false

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
        insightGroup?.insights.first { $0.id == selectedInsightID?.wrappedValue }
    }

    var insightDTO: InsightDataTransferObject? {
        if let selectedInsightID = selectedInsightID?.wrappedValue {
            return api.insightData[selectedInsightID]
        } else { return nil }
    }

    var allInsightGroups: [InsightGroup] {
        if let app = app {
            return api.insightGroups[app] ?? []
        }

        return []
    }

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
        self.selectedInsightGroupIndex = self.allInsightGroups.firstIndex { $0.id == selectedInsightGroupID } ?? 0
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
            groupID: allInsightGroups[selectedInsightGroupIndex].id,
            id: selectedInsightID?.wrappedValue,
            isExpanded: insightIsExpanded)

        if let insight = insight, let insightGroup = insightGroup, let app = app {
            api.update(insight: insight, in: insightGroup, in: app, with: insightDRB) { result in
                switch result {
                case .success(let newInsight):
                    self.selectedInsightGroupID = self.allInsightGroups[self.selectedInsightGroupIndex].id
                case .failure(let error):
                    print(error)
                }
            }
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
}

struct InsightEditor: View {
    @ObservedObject var viewModel: InsightEditorViewModel

    init(viewModel: InsightEditorViewModel) {
        self.viewModel = viewModel
    }

    var padding: CGFloat? {
        #if os(macOS)
        return nil
        #else
        return 0
        #endif
    }

    var pickerStyle: DefaultPickerStyle {
        #if os(macOS)
        return DefaultPickerStyle()
        #else
        return WheelPickerStyle()
        #endif
    }


    // Body
    var body: some View {
        if viewModel.insight != nil {
            Form {
                CustomSection(header: Text("Title, Subtitle and Group"), footer: Text("Give your insight a title, and optionally, add a longer descriptive subtitle for your insight. All insights belong to an insight group.")) {

                    TextField("Title e.g. 'Daily Active Users'", text: $viewModel.insightTitle, onEditingChanged: { if !$0 { viewModel.saveInsight() }}) { viewModel.saveInsight() }
                    TextField("Optional Subtitle", text: $viewModel.insightSubtitle, onEditingChanged: { if !$0 { viewModel.saveInsight() }}) { viewModel.saveInsight() }

                    Toggle(isOn: $viewModel.insightIsExpanded, label: {
                        Text("Show Expanded")
                    })
                    .onChange(of: viewModel.insightIsExpanded) { newValue in
                        viewModel.saveInsight()
                    }

                    Picker(selection: $viewModel.selectedInsightGroupIndex, label: Text("Insight Group")) {
                        ForEach(0 ..< viewModel.allInsightGroups.count) {
                            Text(viewModel.allInsightGroups[$0].title)
                        }
                    }
                    .pickerStyle(pickerStyle)
                    .onChange(of: viewModel.selectedInsightGroupIndex) { newValue in
                        viewModel.saveInsight()
                    }
                }

                if let dto = viewModel.insightDTO {
                    CustomSection(header: Text("Last Updated"), footer: EmptyView()) {
                        Text(dto.calculatedAt, style: .relative) + Text(" ago")
                        Button("Update Now", action: viewModel.updateInsight)
                            .buttonStyle(SmallSecondaryButtonStyle())

                    }
                }

                CustomSection(header: Text("Delete"), footer: EmptyView()) {
                    Button("Delete this Insight", action: viewModel.deleteInsight)
                        .buttonStyle(SmallSecondaryButtonStyle())
                        .accentColor(.red)
                }
            }
            .padding(.horizontal, padding)
        } else {
            Text("No Insight Selected").foregroundColor(.grayColor)
        }
    }
}
