//
//  KeyValueView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 20.10.20.
//

import SwiftUI

struct KeyValueView: View {
    var keysAndValues: [String: String]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading) {
            let theKeys = Array(keysAndValues.keys).sorted()
            
            ForEach(theKeys, id: \.self) { key in
                HStack {
                    Spacer()
                    Text(key)
                        .foregroundColor(.grayColor)
                }
                Text(keysAndValues[key] ?? "–")
                    .lineLimit(1)
                    .font(.system(.body, design: .monospaced))
            }
        }
    }
}

struct KeyValueView_Previews: PreviewProvider {
    static var previews: some View {
        KeyValueView(keysAndValues: [
            "appVersion" : "1.0",
            "signalClientUser" : "535be16c0989f9c9e21729ea7a1051caafce47bf8f3d17abeac770c7ae51644e",
            "isAppStore" : "true",
            "platform" : "macOS",
            "isTestFlight" : "false",
            "buildNumber" : "1",
            "systemVersion" : "macOS 11.0.0",
            "isSimulator" : "false",
            "signalType" : "insightUpdatedAutomatically"
        ])
    }
}
