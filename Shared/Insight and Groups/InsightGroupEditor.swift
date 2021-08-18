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
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var insightService: OldInsightService
    @State var editorContent: InsightGroupEditorContent
    @State private var showingAlert = false

    let appID: UUID

    init(appID: UUID, insightGroup: DTO.InsightGroup) {
        self.appID = appID
        _editorContent = State(initialValue: InsightGroupEditorContent.from(insightGroup: insightGroup))
    }

    func save() {
        insightService.update(insightGroup: editorContent.getInsightGroupDTO(), in: appID)
    }

    func delete() {
        insightService.delete(insightGroupID: editorContent.id, in: appID) { _ in
            presentationMode.wrappedValue.dismiss()
        }
        
    }

    var body: some View {
        let form = Form {
            CustomSection(header: Text("Insight Group Title"), summary: EmptyView(), footer: EmptyView()) {
                TextField("", text: $editorContent.title, onEditingChanged: { isEditing in if !isEditing { save() } }, onCommit: { })
            }

            CustomSection(header: Text("Ordering"), summary: Text(String(format: "%.0f", editorContent.order)), footer: Text("Insights are ordered by this number, ascending"), startCollapsed: true) {
                OrderSetter(order: $editorContent.order)
                    .onChange(of: editorContent.order) { _ in save() }
            }

            CustomSection(header: Text("Delete"), summary: EmptyView(), footer: EmptyView(), startCollapsed: true) {
                Button("Delete this Insight Group", action: { showingAlert = true })
                    .buttonStyle(SmallSecondaryButtonStyle())
                    .accentColor(.red)
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Are you sure you want to delete the group \(editorContent.title)?"),
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
            }
        #else
            form
        #endif
    }
}
