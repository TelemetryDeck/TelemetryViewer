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
    let onEditingChanged: (() -> Void)?

    init(keysAndValues: Binding<[String: String]>, autocompleteOptions: [String]? = nil, onEditingChanged: (() -> Void)? = nil) {
        _keysAndValues = keysAndValues
        self.autocompleteOptions = autocompleteOptions
        self.onEditingChanged = onEditingChanged
    }

    var body: some View {
        let theKeys = Array(keysAndValues.keys).sorted()

        VStack {
            ForEach(theKeys, id: \.self) { key in
                HStack(spacing: 2) {
                        Text(key)
                            .foregroundColor(.grayColor)
                            .frame(width: 70, alignment: .trailing)

                        Text("==")

                        TextField("Value", text: $keysAndValues[key].irreversiblyBound)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Button(action: {
                            keysAndValues[key] = nil
                        }, label: {
                            Image(systemName: "minus.circle")
                        })
                    }.frame(height: 18)

            }

            HStack {
                if let autocompleteOptions = autocompleteOptions {
                    Picker(selection: $newKeyName.bound) {
                        ForEach(autocompleteOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    } label: {
                        Text("Add Key")
                            .frame(width: 85, alignment: .trailing)
                    }
                } else {
                    TextField("Add Key", text: $newKeyName.bound)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                Button(action: {
                    self.keysAndValues[newKeyName.bound] = ""
                    newKeyName = nil
                    onEditingChanged?()
                }, label: {
                    Image(systemName: "plus.circle")
                })
            }
        }
    }
}

struct FilterEditView_Previews: PreviewProvider {
    static var previews: some View {
        FilterEditView(keysAndValues: .constant([
            "appVersion": "1.0",
            "signalClientUser": "535be16c0989f9c9e21729ea7a1051caafce47bf8f3d17abeac770c7ae51644e",
            "isAppStore": "true",
            "platform": "macOS",
            "isTestFlight": "false",
            "buildNumber": "1",
            "systemVersion": "macOS 11.0.0",
            "isSimulator": "false",
            "signalType": "insightUpdatedAutomatically"
        ]), autocompleteOptions: [])
    }
}
