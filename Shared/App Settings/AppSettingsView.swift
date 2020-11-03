//
//  EditAppView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 10.09.20.
//

import SwiftUI
import TelemetryClient

struct AppSettingsView: View {
    @EnvironmentObject var api: APIRepresentative
    var app: TelemetryApp
    @State var newName: String = ""
    
    var body: some View {
        let saveButton = Button("Save Changes") {
            api.update(app: app, newName: newName)
            TelemetryManager.shared.send(TelemetrySignal.telemetryAppUpdated.rawValue, for: api.user?.email)
        }
        .keyboardShortcut(.defaultAction)
        
        let form = Form {
            #if os(macOS)
            Text("App Settings")
                .font(.title2)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
            #endif
            
            Section(header: Text("App Name")) {
                TextField("App Name", text: $newName)
            }
            
            Section(header: Text("Unique Identifier")) {
                VStack(alignment: .leading) {
                    Button (app.id.uuidString) {
                        saveToClipBoard(app.id.uuidString)
                    }
                    Text("Tap to copy this UUID into your apps for tracking.").font(.footnote)
                }
            }
            
            Section(header: Text("Delete")) {
                Button("Delete App \"\(app.name)\"") {
                    api.delete(app: app)
                    TelemetryManager.shared.send(TelemetrySignal.telemetryAppDeleted.rawValue, for: api.user?.email)
                }.accentColor(.red)
            }
            
        }
        
        form
            .navigationTitle("App Settings")
            .toolbar {
                ToolbarItem {
                    saveButton
                }
            }
            .onAppear {
                newName = app.name
                TelemetryManager.shared.send(TelemetrySignal.telemetryAppSettingsShown.rawValue, for: api.user?.email)
            }
    }
}
