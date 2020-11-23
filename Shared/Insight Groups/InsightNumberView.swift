//
//  InsightCountView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 29.09.20.
//

import SwiftUI

struct InsightNumberView: View {
    let insightData: InsightDataTransferObject
    //    var insightHistoricalData: [InsightHistoricalData]
    
    let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.usesGroupingSeparator = true
        return numberFormatter
    }()
    
    let percentageFormatter: NumberFormatter = {
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        return percentageFormatter
    }()
    
//    var currentCount: NSNumber? {
//        guard let textBasedCount = insightData.data.first?["count"] else { return nil }
//        return numberFormatter.number(from: textBasedCount)
//    }
//
//    var previousCount: NSNumber? {
//        guard let textBasedPreviousCount = insightData.data.first?["previousCount"] else { return nil }
//        return numberFormatter.number(from: textBasedPreviousCount)
//    }
//
//    var countText: String {
//        guard let countNumber = currentCount else { return "–" }
//        return numberFormatter.string(from: countNumber) ?? "Couldn't display as String"
//    }
//
//    var previousPercentage: String? {
//        guard let previousCountNumber = previousCount?.doubleValue else { return nil }
//        guard let currentCountNumber = currentCount?.doubleValue else { return nil }
//
//        let percentage: Double = (currentCountNumber - previousCountNumber) / previousCountNumber
//        let percentageNumber = NSNumber(value: percentage)
//
//        guard let string = percentageFormatter.string(from: percentageNumber) else { return nil }
//
//        return "\(percentage > 0 ? "▵" : "▽")\(string)"
//    }
//
//    var previousCountText: String? {
//        guard let countNumber = previousCount else { return nil }
//        return numberFormatter.string(from: countNumber)
//    }
//
//    var previousIntervalText: String? {
//        return "last week"
//    }
//
    
    var body: some View {
        Text("Unsupported")

    }
}

struct InsightNumberView_Previews: PreviewProvider {
    static var previews: some View {
        InsightNumberView(insightData: MockData.exampleInsight1)
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("Default preview")
    }
}
