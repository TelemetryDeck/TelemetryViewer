//
//  InsightGroupEditor.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 25.11.20.
//

import SwiftUI

struct InsightGroupEditor: View {
    let appID: UUID
    private var app: TelemetryApp? { api.apps.first(where: { $0.id == appID }) }

    @Binding var selectedInsightID: UUID?
    @Binding var selectedInsightGroupID: UUID
    @Binding var sidebarSection: AppRootSidebarSection
    @EnvironmentObject var api: APIRepresentative

    var insightGroup: InsightGroup? {
        guard let app = app else { return nil }
        let insightGroup = api.insightGroups[app]?.first(where: { $0.id == selectedInsightGroupID })

        return insightGroup
    }

    @State var order: Double = 0
    @State var title: String = ""

    var padding: CGFloat? {
        #if os(macOS)
        return nil
        #else
        return 0
        #endif
    }

    func saveToAPI() {
        if let app = app, let insightGroup = insightGroup {
            var dto = insightGroup.getDTO()
            dto.title = title
            
            api.update(insightGroup: dto, in: app)
        }

    }

    var body: some View {
        if let insightGroup = insightGroup, let app = app {
            Form {
                CustomSection(header: Text("Insight Group Title"), footer: EmptyView()) {
                    TextField("Title", text: $title, onEditingChanged: { if !$0 { saveToAPI() }}) { saveToAPI() }
                }

                CustomSection(header: Text("New Insight"), footer: Text("Create a new Insight inside this Group")) {
                    Button("New Insight") {
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
                                selectedInsightID = insightDTO.id
                                sidebarSection = .InsightEditor
                            case .failure(let error):
                                print(error)
                            }
                        }
                    }
                }

                CustomSection(header: Text("Delete"), footer: EmptyView(), startCollapsed: true) {
                    Button("Delete this Insight Group") {
                        api.delete(insightGroup: insightGroup, in: app)
                    }
                    .accentColor(.red)
                }
            }
            .padding(.horizontal, self.padding)
            .onDisappear { saveToAPI() }
            .onAppear {
                self.title = insightGroup.title
                self.order = insightGroup.order ?? 0
            }

        } else {
            Text("No Insight Group Selected").foregroundColor(.grayColor)
        }
    }
}
