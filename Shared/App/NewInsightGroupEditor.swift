//
//  NewInsightGroupEditor.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.03.21.
//

import SwiftUI

struct NewInsightGroupEditorContent {
    var id: UUID
    var title: String
    var order: Double

    static func from(insightGroup: InsightGroup) -> NewInsightGroupEditorContent {
        NewInsightGroupEditorContent(
            id: insightGroup.id,
            title: insightGroup.title,
            order: insightGroup.order ?? -1
        )
    }

    func getInsightGroupDTO() -> InsightGroupDTO {
        InsightGroupDTO(id: id, title: title, order: order != -1 ? order : nil)
    }
}

struct NewInsightGroupEditor: View {
    @EnvironmentObject var api: APIRepresentative
    @State var insightGroupDTO: NewInsightGroupEditorContent

    let app: TelemetryApp
    let insightGroup: InsightGroup

    init(app: TelemetryApp, insightGroup: InsightGroup) {
        self.app = app
        self.insightGroup = insightGroup
        _insightGroupDTO = State(initialValue: NewInsightGroupEditorContent.from(insightGroup: insightGroup))
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

        #if os(macOS)
            ScrollView {
                form.padding()
            }
        #else
            form
        #endif
    }
}
