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
    @Environment(\.presentationMode) var presentationMode
    
    let appID: UUID
    private var app: TelemetryApp? { api.apps.first(where: { $0.id == appID }) }
    
    @State private var newName: String = ""
    @State private var showingAlert = false
    
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
                CustomSection(header: Text("App Name"), summary: EmptyView(), footer: EmptyView()) {
                    TextField("App Name", text: $newName, onEditingChanged: { if !$0 { saveToAPI() }}) { saveToAPI() }
                }
                
                CustomSection(header: Text("Unique Identifier"), summary: EmptyView(), footer: EmptyView()) {
                    VStack(alignment: .leading) {
                        Button(app.id.uuidString) {
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
                
                CustomSection(header: Text("Delete"), summary: EmptyView(), footer: EmptyView()) {
                    Button("Delete App \"\(app.name)\"") {
                        showingAlert = true
                    }
                    .buttonStyle(SmallSecondaryButtonStyle())
                    .accentColor(.red)
                }
            }
            .padding(.horizontal, self.padding)
            .navigationTitle("App Settings")
            .onDisappear { saveToAPI() }
            .onAppear {
                newName = app.name
                TelemetryManager.shared.send(TelemetrySignal.telemetryAppSettingsShown.rawValue, for: api.user?.email)
            }
            .toolbar {
                #if os(macOS)
                #else
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                #endif
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Are you sure you want to delete \(app.name)?"),
                    message: Text("This will delete the app, all insights, and all received Signals for this app. There is no undo."),
                    primaryButton: .destructive(Text("Delete")) {
                        api.delete(app: app)
                        presentationMode.wrappedValue.dismiss()
                        TelemetryManager.shared.send(TelemetrySignal.telemetryAppDeleted.rawValue, for: api.user?.email)
                    },
                    secondaryButton: .cancel()
                )
            }
            
        } else {
            Text("No App Selected")
        }
    }
}
