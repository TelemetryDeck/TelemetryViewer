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
                HStack {
                    TextField("New Filter Name", text: $newKeyName.bound)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)

                    Button(action: {
                        self.keysAndValues[newKeyName.bound] = ""
                        newKeyName = nil
                    }, label: {
                        Image(systemName: "plus.circle")
                    })
                    .disabled(newKeyName?.isEmpty != false)
                }
            }
        }
    }
}

struct FilterEditView_Previews: PreviewProvider {
    @State static var keysAndValues: [String: String] = [:]

    static var previews: some View {
        FilterEditView(
            keysAndValues: $keysAndValues,
            autocompleteOptions: [])
    }
}
