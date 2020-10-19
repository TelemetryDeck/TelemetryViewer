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
        return numberFormatter
    }()
    
    var countText: String {
        guard let textBasedCount = insightData.data.first?["count"] else { return "No Count in Data" }
        guard let countNumber = numberFormatter.number(from: textBasedCount) else { return "Couldn't Convert to Number" }
        
        return numberFormatter.string(from: countNumber) ?? "Couldn't display as String"
    }
    
    
    var body: some View {
        Text(countText).font(.system(size: 64, weight: .black, design: .monospaced))
    }

}
