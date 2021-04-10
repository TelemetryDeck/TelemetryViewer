//
//  ChartRangeView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 23.02.21.
//

import SwiftUI
import TelemetryModels

struct ChartRangeView: View {
    let lastValue: Double
    let chartDataSet: ChartDataSet
    let isSelected: Bool

    var body: some View {
        GeometryReader { reader in
            let percentage = 1 - (lastValue / (chartDataSet.highestValue - chartDataSet.lowestValue))

            ZStack {
                if lastValue != chartDataSet.lowestValue && percentage < 0.9 {
                    Text(BigNumberFormatter.shortDisplay(for: chartDataSet.lowestValue.stringValue))
                        .position(x: 10, y: reader.size.height)
                        .foregroundColor(isSelected ? .cardBackground : .none)
                }

                if lastValue != chartDataSet.highestValue && percentage > 0.1 {
                    Text(BigNumberFormatter.shortDisplay(for: chartDataSet.highestValue.stringValue))
                        .position(x: 10, y: 0)
                        .foregroundColor(isSelected ? .cardBackground : .none)
                }

                if !percentage.isNaN {
                    Text(BigNumberFormatter.shortDisplay(for: lastValue.stringValue))
                        .frame(width: 30)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.accentColor)
                        .position(x: 10, y: reader.size.height * CGFloat(percentage))
                }
            }
        }
        .font(.footnote)
        .frame(width: 30)
    }
}
