//
//  InsightCountView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 29.09.20.
//

import SwiftUI

struct InsightLineChartView: View {
    let insightData: InsightDataTransferObject

    let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        return numberFormatter
    }()
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        return dateFormatter
    }()

    
    var body: some View {
        #if os(macOS)
        let paddingBottom: CGFloat = -37
        #else
        let paddingBottom: CGFloat = -40
        #endif
        
        LineChartView(data: insightData.data.compactMap {
            guard let dayStringValue = $0["day"],
                  let day = dateFormatter.date(from: dayStringValue),
                  let countStringValue = $0["count"],
                  let count = numberFormatter.number(from: countStringValue)?.doubleValue
            else { return nil }
                        
            return ChartDataPoint(date: day, value: count)
        })
            .padding(.bottom, paddingBottom)
            .padding(.leading, -16)
    }
}

struct InsightCountView_Previews: PreviewProvider {
    static var previews: some View {
        let insightDTO = InsightDataTransferObject(
            id: UUID(),
            order: nil,
            title: "",
            subtitle: nil,
            signalType: nil,
            uniqueUser: false,
            filters: [:],
            rollingWindowSize: -24*3600,
            breakdownKey: nil,
            displayMode: .lineChart,
            data: [
                [
                  "count" : "4",
                  "day" : "2020-10-05 00:00:00+02"
                ],
                [
                  "count" : "5",
                  "day" : "2020-10-06 00:00:00+02"
                ],
                [
                  "count" : "12",
                  "day" : "2020-10-07 00:00:00+02"
                ],
                [
                  "count" : "8",
                  "day" : "2020-10-08 00:00:00+02"
                ],
                [
                  "count" : "2",
                  "day" : "2020-10-09 00:00:00+02"
                ],
                [
                  "day" : "2020-10-10 00:00:00+02",
                  "count" : "8"
                ],
                [
                  "day" : "2020-10-11 00:00:00+02",
                  "count" : "7"
                ],
                [
                  "count" : "6",
                  "day" : "2020-10-12 00:00:00+02"
                ],
                [
                  "count" : "10",
                  "day" : "2020-10-13 00:00:00+02"
                ],
                [
                  "count" : "6",
                  "day" : "2020-10-14 00:00:00+02"
                ],
                [
                  "day" : "2020-10-15 00:00:00+02",
                  "count" : "3"
                ],
                [
                  "day" : "2020-10-16 00:00:00+02",
                  "count" : "2"
                ],
                [
                  "day" : "2020-10-17 00:00:00+02",
                  "count" : "2"
                ]
            ],
            calculatedAt: Date())
        
        InsightLineChartView(insightData: insightDTO)
        .environmentObject(APIRepresentative())
        .previewLayout(.fixed(width: 300, height: 300))
    }
}
