//
//  InsightBreakdownView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.09.20.
//

import SwiftUI

//struct InsightBreakdownView: View {
//    let insightData: InsightDataTransferObject
//    
//    let numberFormatter: NumberFormatter = {
//        let numberFormatter = NumberFormatter()
//        return numberFormatter
//    }()
//    
//    var body: some View {
//        let breakdowns = insightData.data
//            .map { ($0.key, $0.value) }
//            .sorted { $0.1 > $1.1 }
//            .map { DonutChartDataPoint(key: $0.0, value: $0.1) }
//        
//        DonutChartView(dataPoints: breakdowns)
//            .frame(minHeight: 140)
//            .padding(.bottom, -25)
//            .padding(.top, -25)
//    }
//}
//
//struct InsightBreakdownView_Previews: PreviewProvider {
//    static var platform: PreviewPlatform? = nil
//    
//    
//    static var previews: some View {
//        InsightBreakdownView(insightData: InsightDataTransferObject(
//                                id: UUID(),
//                                title: "System Version",
//                                insightType: .breakdown,
//                                timeInterval: -3600*24,
//                                configuration: ["breakdown.payloadKey": "systemVersion"],
//                                data: ["macOS 11.0.0": 1394, "iOS 14": 840, "iOS 13": 48],
//                                calculatedAt: Date(timeIntervalSinceNow: -36)))
//            .environmentObject(APIRepresentative())
//            .previewLayout(.fixed(width: 300, height: 300))
//    }
//}
