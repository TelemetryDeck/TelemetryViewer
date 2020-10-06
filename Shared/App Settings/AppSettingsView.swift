//
//  EditAppView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 10.09.20.
//

import SwiftUI
import TelemetryClient

struct AppSettingsView: View {
    @Binding var isPresented: Bool

    @EnvironmentObject var telemetryManager: TelemetryManager
    @EnvironmentObject var api: APIRepresentative
    var app: TelemetryApp
    @State var newName: String = ""
    
    var body: some View {
        let saveButton = Button("Save Changes") {
            api.update(app: app, newName: newName)
            isPresented = false
            telemetryManager.send(TelemetrySignal.telemetryAppUpdated.rawValue, for: api.user?.email)
        }
        .keyboardShortcut(.defaultAction)
        
        let cancelButton = Button("Cancel") {
            isPresented = false
        }
        .keyboardShortcut(.cancelAction)
        
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
                    TextField("", text: .constant(app.id.uuidString))
                    Text("Copy this UUID into your apps for tracking.").font(.footnote)
                }
            }
            
            Section(header: Text("Delete")) {
                Button("Delete App \"\(app.name)\"") {
                    api.delete(app: app)
                    isPresented = false
                    telemetryManager.send(TelemetrySignal.telemetryAppDeleted.rawValue, for: api.user?.email)
                }.accentColor(.red)
            }
            
            #if os(macOS)
            HStack {
                cancelButton
                Spacer()
                saveButton
            }
            #endif
            
        }
        
        
        #if os(macOS)
        form
            .padding()
            .onAppear {
                newName = app.name
                telemetryManager.send(TelemetrySignal.telemetryAppSettingsShown.rawValue, for: api.user?.email)
            }
        #else
        NavigationView {
            form
                .navigationTitle("App Settings")
                .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
        .onAppear {
            newName = app.name
            telemetryManager.send(TelemetrySignal.telemetryAppSettingsShown.rawValue, for: api.user?.email)
        }
        #endif
        
    }
}
