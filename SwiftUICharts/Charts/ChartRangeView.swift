//
//  ChartRangeView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 23.02.21.
//

import SwiftUI
import WidgetKit

struct ChartRangeView: View {
    let lastValue: Double
    let chartDataSet: ChartDataSet
    let isSelected: Bool

    @Environment(\.widgetFamily) var family: WidgetFamily

    var body: some View {
        GeometryReader { reader in
            let percentage = 1 - (lastValue / Double(chartDataSet.highestValue - chartDataSet.lowestValue))

            ZStack(alignment: .trailing) {
                if percentage > 0.1 {
                    Text(BigNumberFormatter.shortDisplay(for: "\(chartDataSet.highestValue)"))
                        .lineLimit(1)
                        .position(x: 10, y: family.isTiny ? 5 : 0)
                        .foregroundColor(isSelected ? .cardBackground : .none)
                }

                if !percentage.isNaN {
                    Text(BigNumberFormatter.shortDisplay(for: "\(lastValue)"))
                        
                        .lineLimit(1)
                        .foregroundColor(.accentColor)
                        .position(x: 10, y: reader.size.height * CGFloat(percentage))
                }
                
                if percentage < 0.9 {
                    Text(BigNumberFormatter.shortDisplay(for: "\(chartDataSet.lowestValue)"))
                        .position(x: 10, y: family.isTiny ? reader.size.height - 5 : reader.size.height)
                        .foregroundColor(isSelected ? .cardBackground : .none)
                }
            }
        }
        .font(family.isSmall ? Font.system(size: 12, design: .default) : .footnote)
        .frame(maxWidth: family.isSmall ? 25 : 30)
    }
}
