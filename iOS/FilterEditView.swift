//
//  FilterEditView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 20.10.20.
//

import SwiftUI



struct FilterEditView: View {
    @Binding var keysAndValues: [String: String]
    let autocompleteOptions: [String]?
    @State private var newKeyName: String?
    
    var body: some View {
        let theKeys = Array(keysAndValues.keys).sorted()
        
        List {
            Section {
                ForEach(theKeys, id: \.self) { key in
                    HStack {
                        Text(key).foregroundColor(.grayColor)
                        
                        TextField("Value", text: $keysAndValues[key].irreversiblyBound)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            
                        Button(action: {
                            keysAndValues[key] = nil
                        }, label: {
                            Image(systemName: "minus.circle")
                        })
                    }
                }
            }
            
            Section {
                TextField("New Filter Name", text: $newKeyName.bound)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                Button("Add") {
                    self.keysAndValues[newKeyName.bound] = ""
                    newKeyName = nil
                }
            }
        }
    }
}

//struct FilterEditView_Previews: PreviewProvider {
//    static var previews: some View {
//        FilterEditView(keysAndValues: .constant([
//            "appVersion" : "1.0",
//            "signalClientUser" : "535be16c0989f9c9e21729ea7a1051caafce47bf8f3d17abeac770c7ae51644e",
//            "isAppStore" : "true",
//            "platform" : "macOS",
//            "isTestFlight" : "false",
//            "buildNumber" : "1",
//            "systemVersion" : "macOS 11.0.0",
//            "isSimulator" : "false",
//            "signalType" : "insightUpdatedAutomatically"
//        ]))
//    }
//}
