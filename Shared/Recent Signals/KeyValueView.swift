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
        let theKeys = Array(keysAndValues.keys).sorted()
        VStack(alignment: .leading) {
            ForEach(theKeys, id: \.self) { key in
                Text(String(key).camelCaseToWords)
                    .font(Font.body.weight(.bold))
                    .opacity(0.7)
                Text(keysAndValues[key] ?? "–")
                    .padding(.bottom, 3)
            }
        }
    }
}

struct KeyValueView_Previews: PreviewProvider {
    static var previews: some View {
        KeyValueView(keysAndValues: [
            "appVersion": "1.0",
            "signalClientUser": "535be16c0989f9c9e21729ea7a1051caafce47bf8f3d17abeac770c7ae51644e",
            "isAppStore": "true",
            "platform": "macOS",
            "isTestFlight": "false",
            "buildNumber": "1",
            "systemVersion": "macOS 11.0.0",
            "isSimulator": "false",
            "signalType": "insightUpdatedAutomatically",
        ])
    }
}
