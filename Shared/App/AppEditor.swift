//
//  EditAppView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 10.09.20.
//

import SwiftUI
import TelemetryClient

struct AppEditor: View {
    @EnvironmentObject var appService: AppService
    
    let appID: UUID
    
    @State private var newName: String = ""
    @State private var showingAlert = false
    
    func saveToAPI() {
        appService.update(appID: appID, newName: newName)
    }
    
    var padding: CGFloat? {
        #if os(macOS)
        return nil
        #else
        return 0
        #endif
    }
    
    var body: some View {
        if let app = appService.getSelectedApp() {
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
                
                Spacer()
            }
            .padding(.horizontal, self.padding)
            .padding(.vertical, self.padding)
            .navigationTitle("App Settings")
            .onDisappear { saveToAPI() }
            .onAppear {
                newName = appService.getSelectedApp()?.name ?? "----"
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Are you sure you want to delete \(app.name)?"),
                    message: Text("This will delete the app, all insights, and all received Signals for this app. There is no undo."),
                    primaryButton: .destructive(Text("Delete")) {
                        appService.delete(appID: appID)
                    },
                    secondaryButton: .cancel()
                )
            }
            
        } else {
            Text("No App Selected")
        }
    }
}
