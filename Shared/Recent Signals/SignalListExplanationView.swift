//
//  SignalListExplanationView.swift
//  Telemetry Viewer
//
//  Created by Martin Václavík on 26.12.2021.
//

import SwiftUI

struct SignalListExplanationView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("These are the latest signals TelemetryDeck has received from your app.")
            Text("Timestamps have a granularity of one hour, and multiple identical signals might get grouped into one entry using the 'count' property.")
        }
        .font(.footnote)
        .foregroundColor(.grayColor)
    }
}


struct SignalListExplanationView_Previews: PreviewProvider {
    static var previews: some View {
        SignalListExplanationView()
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
