//
//  InsightPieChartView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.09.20.
//

import SwiftUI

struct InsightPieChartView: View {
    let insightData: InsightDataTransferObject
    
    let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        return numberFormatter
    }()
    
    var body: some View {
        Text("unsupported")
//        let breakdowns = insightData.data
//            .compactMap { (dataRow: [String: String]) -> DonutChartDataPoint? in
//
//                guard
//                    let key = dataRow.keys.first(where: { key in key != "count" })?.description,
//                    let valueString = dataRow["count"],
//                    let value = numberFormatter.number(from: valueString)
//                else { return nil }
//
//
//                return DonutChartDataPoint(key: dataRow[key] ?? "No Key", value: value.doubleValue)
//            }
//
//        DonutChartView(dataPoints: breakdowns)
//            .frame(minHeight: 140)
//            .padding(.bottom, -25)
//            .padding(.top, -25)
    }
}

//struct InsightBreakdownView_Previews: PreviewProvider {
//    static var platform: PreviewPlatform? = nil
//    
//    
//    static var previews: some View {
//        let insightDTO = InsightDataTransferObject(
//            id: UUID(),
//            order: 7.5,
//            title: "",
//            subtitle: nil,
//            signalType: nil,
//            uniqueUser: false,
//            filters: [:],
//            rollingWindowSize: -24*3600,
//            breakdownKey: "platform",
//            displayMode: .pieChart,
//            data: [
//                ["count" : "373", "platform": "macOS"],
//                ["count" : "473", "platform": "iOS"],
//                ["count" : "22", "platform": "watchOS"],
//            ],
//            calculatedAt: Date())
//        InsightPieChartView(insightData: insightDTO)
//    }
//}
