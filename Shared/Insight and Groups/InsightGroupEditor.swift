//
//  InsightGroupEditor.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.03.21.
//

import SwiftUI
import TelemetryClient

struct InsightGroupEditor: View {
    @Environment(\.presentationMode) var presentationMode

    @EnvironmentObject var api: APIClient
    @EnvironmentObject var insightService: OldInsightService
    @EnvironmentObject var groupService: GroupService
    @EnvironmentObject var appService: AppService

    let appID: UUID
    let id: UUID

    @State var title: String
    @State var order: Double

    @State private var showingAlert = false

    init(groupID: DTOv2.Group.ID, appID: DTOv2.App.ID, title: String, order: Double) {
        self.id = groupID
        self.appID = appID
        self._title = State(initialValue: title)
        self._order = State(initialValue: order)
        self._showingAlert = State(initialValue: false)
    }

    func save() {
        insightService.update(insightGroup: DTOv1.InsightGroup(id: id, title: title, order: order), in: appID) { _ in
            groupService.retrieveGroup(with: self.id)
        }
    }

    func delete() {
        insightService.delete(insightGroupID: id, in: appID) { _ in
            #if os(iOS)
                presentationMode.wrappedValue.dismiss()
            #endif

            appService.retrieveApp(with: appID)
        }
    }

    var body: some View {
        let form = Form {
            CustomSection(header: Text("Insight Group Title"), summary: EmptyView(), footer: EmptyView()) {
                TextField("", text: $title, onEditingChanged: { isEditing in if !isEditing { save() } }, onCommit: {})
            }

            CustomSection(header: Text("Ordering"), summary: Text(String(format: "%.0f", order)), footer: Text("Insights are ordered by this number, ascending"), startCollapsed: true) {
                OrderSetter(order: $order)
                    .onChange(of: order) { _ in save() }
            }

            CustomSection(header: Text("Delete"), summary: EmptyView(), footer: EmptyView(), startCollapsed: true) {
                Button("Delete this Insight Group", action: { showingAlert = true })
                    .buttonStyle(SmallSecondaryButtonStyle())
                    .accentColor(.red)
            }
        }
        .onAppear {
            TelemetryManager.send("InsightGroupEditorAppear")
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Are you sure you want to delete the group \(title)?"),
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
                .onAppear {
                    UITableView.appearance().backgroundColor = .clear
                }
                .onDisappear {
                    UITableView.appearance().backgroundColor = .systemGroupedBackground
                }
        #endif
    }
}
