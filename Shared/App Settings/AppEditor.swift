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
                CustomSection(header: Text("App Name"), footer: EmptyView()) {
                    TextField("App Name", text: $newName, onEditingChanged: { if !$0 { saveToAPI() }}) { saveToAPI() }
                }

                CustomSection(header: Text("Unique Identifier"), footer: EmptyView()) {
                    VStack(alignment: .leading) {
                        Button (app.id.uuidString) {
                            saveToClipBoard(app.id.uuidString)
                        }
                        .buttonStyle(SmallPrimaryButtonStyle())
                        #if os(macOS)
                        Text("Click to copy this UUID into your apps for tracking.").font(.footnote)
                        #else
                        Text("Tap to copy this UUID into your apps for tracking.").font(.footnote)
                        #endif
                    }
                }

                CustomSection(header: Text("New Insight Group"), footer: EmptyView()) {
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
                    .buttonStyle(SmallSecondaryButtonStyle())
                }
                
               CustomSection(header: Text("Delete"), footer: EmptyView()) {
                    Button("Delete App \"\(app.name)\"") {
                        api.delete(app: app)
                        TelemetryManager.shared.send(TelemetrySignal.telemetryAppDeleted.rawValue, for: api.user?.email)
                    }
                    .buttonStyle(SmallSecondaryButtonStyle())
                    .accentColor(.red)
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
