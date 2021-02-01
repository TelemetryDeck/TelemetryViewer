//
//  ValueView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 01.02.21.
//

import SwiftUI

struct ValueView: View {
    let value: Double
    let title: String
    let unit: String

    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading) {
            Text((formatter.string(from: NSNumber(value: value)) ?? "–") + unit)
                .font(.system(size: 28, weight: .light, design: .rounded))
            Text(title)
                .foregroundColor(.gray)
                .font(.system(size: 12, weight: .light, design: .default))
        }
        .padding()
    }
}

struct ValueView_Previews: PreviewProvider {
    static var previews: some View {
        ValueView(value: 98.833333, title: "Average", unit: "s")
    }
}
