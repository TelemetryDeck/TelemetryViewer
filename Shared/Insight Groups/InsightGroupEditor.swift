//
//  InsightGroupEditor.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 25.11.20.
//

import SwiftUI

class InsightGroupEditorViewModel: ObservableObject {
    @Published var order: Double = 0
    @Published var title: String = ""

    @ObservedObject private var api: APIRepresentative
    private let appID: UUID
    @Binding private var selectedInsightID: UUID?
    private var selectedInsightGroupID: Binding<UUID>? = nil
    @Binding private var sidebarSection: AppRootSidebarSection

    init(api: APIRepresentative, appID: UUID, selectedInsightGroupID: Binding<UUID>, selectedInsightID: Binding<UUID?>, sidebarSection: Binding<AppRootSidebarSection>) {

        self.api = api
        self.appID = appID
        self._selectedInsightID = selectedInsightID
        self._sidebarSection = sidebarSection

        self.selectedInsightGroupID = Binding(get: {
            selectedInsightGroupID.wrappedValue
        }, set: { newValue in
            selectedInsightGroupID.wrappedValue = newValue
            self.updateWithInsightGroup()
        })

        self.updateWithInsightGroup()
    }

    var app: TelemetryApp? { api.apps.first(where: { $0.id == appID }) }

    var insightGroup: InsightGroup? {
        guard let app = app else { return nil }
        let insightGroup = api.insightGroups[app]?.first(where: { $0.id == selectedInsightGroupID?.wrappedValue })

        return insightGroup
    }

    func updateWithInsightGroup() {
        self.order = insightGroup?.order ?? -1
        self.title = insightGroup?.title ?? ""
    }

    func createNewInsight() {
        if let app = app, let insightGroup = insightGroup {

        let definitionRequestBody = InsightDefinitionRequestBody(
            order: nil,
            title: "New Insight",
            subtitle: nil,
            signalType: nil,
            uniqueUser: false,
            filters: [:],
            rollingWindowSize: -2592000,
            breakdownKey: nil,
            displayMode: .lineChart,
            groupID: insightGroup.id,
            id: nil,
            isExpanded: false)

            api.create(insightWith: definitionRequestBody, in: insightGroup, for: app) { result in
                switch result {
                case .success(let insightDTO):
                    self.selectedInsightID = insightDTO.id
                    self.sidebarSection = .InsightEditor
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    func saveToAPI() {
        if let app = app, let insightGroup = insightGroup {
            var dto = insightGroup.getDTO()
            dto.title = title

            api.update(insightGroup: dto, in: app)
        }
    }

    func delete() {
        if let app = app, let insightGroup = insightGroup {
            api.delete(insightGroup: insightGroup, in: app)
        }
    }
}

struct InsightGroupEditor: View {
    @ObservedObject var viewModel: InsightGroupEditorViewModel

    init(viewModel: InsightGroupEditorViewModel) {
        self.viewModel = viewModel
    }

    var padding: CGFloat? {
        #if os(macOS)
        return nil
        #else
        return 0
        #endif
    }

    var body: some View {
        if viewModel.insightGroup != nil {
            Form {
                CustomSection(header: Text("Insight Group Title"), footer: EmptyView()) {
                    TextField("Title", text: $viewModel.title, onEditingChanged: { if !$0 { viewModel.saveToAPI() }}) { viewModel.saveToAPI() }
                }

                CustomSection(header: Text("New Insight"), footer: Text("Create a new Insight inside this Group")) {
                    Button("New Insight", action: viewModel.createNewInsight)
                        .buttonStyle(SmallPrimaryButtonStyle())
                }

                CustomSection(header: Text("Delete"), footer: EmptyView(), startCollapsed: true) {
                    Button("Delete this Insight Group", action: viewModel.delete)
                        .buttonStyle(SmallSecondaryButtonStyle())
                        .accentColor(.red)
                }
            }
            .padding(.horizontal, self.padding)
            .onDisappear { viewModel.saveToAPI() }

        } else {
            Text("No Insight Group Selected").foregroundColor(.grayColor)
        }
    }
}
