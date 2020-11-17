//
//  InsightCountView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 29.09.20.
//

import SwiftUI

struct InsightBarChartView: View {
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
        let dataPoints: [ChartDataPoint] = insightData.data.compactMap { 
            guard let dayStringValue = $0["day"],
                  let day = dateFormatter.date(from: dayStringValue),
                  let countStringValue = $0["count"],
                  let count = numberFormatter.number(from: countStringValue)?.doubleValue
            else { return nil }
                        
            return ChartDataPoint(date: day, value: count)
        }
        
        if let chartData = try? ChartData(data: dataPoints) {
            BarChartView(data: chartData)
        } else {
            Text("Not Enough Data").foregroundColor(.grayColor)
        }
        
    }
}
