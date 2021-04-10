//
//  InsightGroupEditor.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.03.21.
//

import SwiftUI
import TelemetryModels

struct InsightGroupEditorContent {
    var id: UUID
    var title: String
    var order: Double

    static func from(insightGroup: InsightGroup) -> InsightGroupEditorContent {
        InsightGroupEditorContent(
            id: insightGroup.id,
            title: insightGroup.title,
            order: insightGroup.order ?? -1
        )
    }

    func getInsightGroupDTO() -> InsightGroupDTO {
        InsightGroupDTO(id: id, title: title, order: order != -1 ? order : nil)
    }
}

struct InsightGroupEditor: View {
    @EnvironmentObject var api: APIRepresentative
    @State var insightGroupDTO: InsightGroupEditorContent

    let app: TelemetryApp
    let insightGroup: InsightGroup

    init(app: TelemetryApp, insightGroup: InsightGroup) {
        self.app = app
        self.insightGroup = insightGroup
        _insightGroupDTO = State(initialValue: InsightGroupEditorContent.from(insightGroup: insightGroup))
    }

    func save() {
        api.update(insightGroup: insightGroupDTO.getInsightGroupDTO(), in: app)
    }

    func delete() {
        api.delete(insightGroup: insightGroup, in: app)
    }

    var body: some View {
        let form = Form {
            CustomSection(header: Text("Insight Group Title"), summary: EmptyView(), footer: EmptyView()) {
                TextField("Title", text: $insightGroupDTO.title, onEditingChanged: { _ in save() }, onCommit: { save() })
            }

            CustomSection(header: Text("Ordering"), summary: Text(String(format: "%.0f", insightGroupDTO.order)), footer: Text("Insights are ordered by this number, ascending"), startCollapsed: true) {
                OrderSetter(order: $insightGroupDTO.order)
                    .onChange(of: insightGroupDTO.order) { _ in save() }
            }

            CustomSection(header: Text("Delete"), summary: EmptyView(), footer: EmptyView(), startCollapsed: true) {
                Button("Delete this Insight Group", action: delete)
                    .buttonStyle(SmallSecondaryButtonStyle())
                    .accentColor(.red)
            }
        }

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
            form
        #endif
    }
}
