//
//  NewAppView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 07.09.20.
//

import SwiftUI

struct NewAppView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var api: APIRepresentative
    @Environment(\.presentationMode) var presentationMode
    @State var newAppName: String = ""
    
    var body: some View {
        
        let saveButton = Button("Save") {
            api.create(appNamed: newAppName)
            self.presentationMode.wrappedValue.dismiss()
            TelemetryManager().send(.telemetryAppCreated, for: api.user?.email)
        }
        .keyboardShortcut(.defaultAction)
        
        let cancelButton = Button("Cancel") {
            self.presentationMode.wrappedValue.dismiss()
        }
        .keyboardShortcut(.cancelAction)
        
        let form = Form {
        
            #if os(macOS)
            Text("New App")
                .font(.title2)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
            #endif
            
            Section(header: Text("App Name"), footer: Text("What is your new app called?")) {
                TextField("Name", text: $newAppName)
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
        form.padding()
        #else
        NavigationView {
            form
                .navigationTitle("New Appp")
                .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
        #endif
    }
}
