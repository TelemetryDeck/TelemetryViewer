//
//  InsightCountView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 29.09.20.
//

import SwiftUI

struct InsightCountView: View {
    let insightData: InsightDataTransferObject
    var insightHistoricalData: [InsightHistoricalData]
    
    let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        return numberFormatter
    }()
    
    var body: some View {
        ZStack {
            LineChartView(data: insightHistoricalData.map { ChartDataPoint(date: $0.calculatedAt, value: $0.data["count"] ?? 0) })
//                .blur(radius: 3.0)
                .padding(.bottom, -37)
                .padding(.horizontal, -16)
            
            HStack {
                Spacer()
                if let count = insightData.data["count"], let countText = numberFormatter.string(from: NSNumber(value: count)) {
                    Text(countText).font(.system(size: 64, weight: .black, design: .monospaced))
                } else {
                    Text("–").font(.system(size: 64, weight: .black, design: .monospaced))
                }
            }
            .padding(.horizontal)
            .shadow(color: Color("CardBackgroundColor"), radius: 10, x: 0.0, y: 0.0)
        }
        
        
    }
}

struct InsightCountView_Previews: PreviewProvider {
    static var previews: some View {
        InsightCountView(insightData: InsightDataTransferObject(
                            id: UUID(),
                            title: "System Version",
                            insightType: .count,
                            timeInterval: -3600*24,
                            configuration: [:],
                            data: ["count": 1394],
                            calculatedAt: Date(timeIntervalSinceNow: -36)),
                         insightHistoricalData: [])
        .environmentObject(APIRepresentative())
        .previewLayout(.fixed(width: 300, height: 300))
    }
}
