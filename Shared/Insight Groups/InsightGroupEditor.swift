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

    @Binding var selectedInsightGroupID: UUID
    @EnvironmentObject var api: APIRepresentative

    var insightGroup: InsightGroup? {
        guard let app = app else { return nil }
        let insightGroup = api.insightGroups[app]?.first(where: { $0.id == selectedInsightGroupID })

        if let insightGroup = insightGroup {
            DispatchQueue.main.async {
                self.title = insightGroup.title
                self.order = insightGroup.order ?? 0
            }
        }

        return insightGroup
    }

    @State var order: Double = 0
    @State var title: String = ""

    func saveToAPI() {
        if let app = app, let insightGroup = insightGroup {
            var dto = insightGroup.getDTO()
            dto.title = title
            dto.order = order
            
            api.update(insightGroup: dto, in: app)
        }

    }

    var body: some View {
        if let insightGroup = insightGroup, let app = app {
            Form {
                Section(header: Text("Insight Group Title")) {
                    TextField("Title", text: $title.onUpdate(saveToAPI))
                }

                Section(header: Text("Order")) {
                    Slider(value: $order.onUpdate(saveToAPI), in: 0...10, step: 1)
                }

                Section(header: Text("Delete")) {
                    Button("Delete this Insight Group") {
                        api.delete(insightGroup: insightGroup, in: app)
                    }
                }
            }

        } else {
            Text("No Insight Group Selected").foregroundColor(.grayColor)
        }
    }
}
