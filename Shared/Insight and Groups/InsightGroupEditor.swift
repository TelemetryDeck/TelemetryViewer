//
//  InsightGroupEditor.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.03.21.
//

import SwiftUI
import TelemetryClient
import DataTransferObjects

struct InsightGroupEditor: View {
    @Environment(\.presentationMode) var presentationMode

    @EnvironmentObject var api: APIClient
    @EnvironmentObject var insightService: InsightService
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
        groupService.update(insightGroup: DTOv2.Group(id: id, title: title, order: order, appID: appID, insightIDs: []), in: appID) { _ in
            groupService.retrieveGroup(with: self.id)
        }
    }

    func delete() {
        groupService.delete(insightGroupID: id, in: appID) { _ in
            #if os(iOS)
                presentationMode.wrappedValue.dismiss()
            #endif

            Task {
                if let app = try? await appService.retrieveApp(withID: appID) {
                    DispatchQueue.main.async {
                        appService.appDictionary[appID] = app
                        appService.app(withID: appID)?.insightGroupIDs.forEach({ groupID in
                            groupService.retrieveGroup(with: groupID)
                        })
                    }
                }
            }
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
        #endif
    }
}
