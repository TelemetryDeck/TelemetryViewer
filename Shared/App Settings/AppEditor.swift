//
//  EditAppView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 10.09.20.
//

import SwiftUI
import TelemetryClient

struct AppEditor: View {
    @EnvironmentObject var api: APIRepresentative

    let appID: UUID
    private var app: TelemetryApp? { api.apps.first(where: { $0.id == appID }) }

    @Binding var selectedInsightGroupID: UUID
    @Binding var sidebarSection: AppRootSidebarSection

    @State private var newName: String = ""

    func saveToAPI() {
        if let app = app {
            api.update(app: app, newName: newName)
        }
    }

    var padding: CGFloat? {
        #if os(macOS)
        return nil
        #else
        return 0
        #endif
    }
    
    var body: some View {
        if let app = app {
            Form {
                Section(header: Text("App Name")) {
                    TextField("App Name", text: $newName, onEditingChanged: { if !$0 { saveToAPI() }}) { saveToAPI() }
                }

                Section(header: Text("Unique Identifier")) {
                    VStack(alignment: .leading) {
                        Button (app.id.uuidString) {
                            saveToClipBoard(app.id.uuidString)
                        }
                        Text("Tap to copy this UUID into your apps for tracking.").font(.footnote)
                    }
                }

                Section(header: Text("New Insight Group")) {
                    Button("New Insight Group") {
                        api.create(insightGroupNamed: "New Insight Group", for: app) { result in
                            switch result {
                            case .success(let insightGroup):
                                selectedInsightGroupID = insightGroup.id
                                sidebarSection = .InsightGroupEditor
                            case .failure(let error):
                                print(error.localizedDescription)
                            }

                        }
                    }
                }
                
                Section(header: Text("Delete")) {
                    Button("Delete App \"\(app.name)\"") {
                        api.delete(app: app)
                        TelemetryManager.shared.send(TelemetrySignal.telemetryAppDeleted.rawValue, for: api.user?.email)
                    }.accentColor(.red)
                }

            }
            .padding(.horizontal, self.padding)
            .onDisappear { saveToAPI() }
            .onAppear {
                newName = app.name
                TelemetryManager.shared.send(TelemetrySignal.telemetryAppSettingsShown.rawValue, for: api.user?.email)
                
                // UITableView.appearance().backgroundColor = .clear
            }
        } else {
            Text("No App")
        }
    }
}
