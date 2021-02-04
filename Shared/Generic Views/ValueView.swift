//
//  ValueView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 01.02.21.
//

import SwiftUI

struct ValueView: View {
    @State var showFullNumber: Bool = false

    let value: Double
    let title: String
    let unit: String
    let shouldFormatBigNumbers: Bool
    let isLoading: Bool

    init(value: Double, title: String, unit: String = "", isLoading: Bool = false, shouldFormatBigNumbers: Bool = false) {
        self.value = value
        self.title = title
        self.unit = unit
        self.isLoading = isLoading
        self.shouldFormatBigNumbers = shouldFormatBigNumbers
    }

    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    var formattedNumberString: String {
        if shouldFormatBigNumbers && !showFullNumber {
            return BigNumberFormatter.shortDisplay(for: value)
        } else {
            return formatter.string(from: NSNumber(value: value)) ?? "–"
        }
    }

    var body: some View {
        VStack(alignment: .trailing) {
            if isLoading {
                ProgressView()
                    .transition(.opacity)
            } else {
                Text(formattedNumberString + unit)
                    .font(.system(size: 28, weight: .light, design: .rounded))
                    .transition(.opacity)
                    .animation(.easeInOut)
            }
            Text(title)
                .foregroundColor(.gray)
                .font(.system(size: 12, weight: .light, design: .default))
        }
        .padding()
        .onHover { over in
            self.showFullNumber = over
        }
    }
}

struct ValueView_Previews: PreviewProvider {
    static var previews: some View {
        ValueView(value: 98.833333, title: "Average", unit: "s", isLoading: true)
    }
}
