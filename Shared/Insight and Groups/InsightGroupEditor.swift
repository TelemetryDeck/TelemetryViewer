//
//  InsightGroupEditor.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.03.21.
//

import SwiftUI

struct InsightGroupEditorContent {
    var id: UUID
    var title: String
    var order: Double

    static func from(insightGroup: DTO.InsightGroup) -> InsightGroupEditorContent {
        InsightGroupEditorContent(
            id: insightGroup.id,
            title: insightGroup.title,
            order: insightGroup.order ?? -1
        )
    }

    func getInsightGroupDTO() -> DTO.InsightGroup {
        DTO.InsightGroup(id: id, title: title, order: order != -1 ? order : nil)
    }
}

struct InsightGroupEditor: View {
    @EnvironmentObject var api: APIRepresentative
    @EnvironmentObject var insightService: InsightService
    @State var insightGroupDTO: InsightGroupEditorContent
    @State private var showingAlert = false

    let appID: UUID
    let insightGroup: DTO.InsightGroup

    init(appID: UUID, insightGroup: DTO.InsightGroup) {
        self.appID = appID
        self.insightGroup = insightGroup
        _insightGroupDTO = State(initialValue: InsightGroupEditorContent.from(insightGroup: insightGroup))
    }

    func save() {
        insightService.update(insightGroup: insightGroup, in: appID)
    }

    func delete() {
        insightService.delete(insightGroupID: insightGroup.id, in: appID)
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
                Button("Delete this Insight Group", action: { showingAlert = true })
                    .buttonStyle(SmallSecondaryButtonStyle())
                    .accentColor(.red)
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Are you sure you want to delete the group \(insightGroup.title)?"),
                message: Text("This will delete the Insight Group and all its Insights. Your signals are not affected."),
                primaryButton: .destructive(Text("Delete")) {
                    delete()
                },
                secondaryButton: .cancel()
            )
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
