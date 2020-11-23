//
//  RawChartView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 22.11.20.
//

import SwiftUI

struct RawChartView: View {
    var insightDataID: UUID
    
    @EnvironmentObject var api: APIRepresentative
    
    private var insightData: InsightDataTransferObject? {
        api.insightData[insightDataID]
    }
    
    private let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.usesGroupingSeparator = true
        return numberFormatter
    }()
    
    private let columns = [
        GridItem(.flexible(maximum: 200), spacing: nil, alignment: .leading),
        GridItem(.flexible(), spacing: nil, alignment: .trailing)
    ]
    
    var body: some View {
        if insightData == nil {
            Text("No Data")
                .foregroundColor(.grayColor)
        } else {
            
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(insightData?.data ?? [], id: \.xAxisValue) { dataRow in
                        Text(dataRow.xAxisValue)
                        Text(dataRow.yAxisValue ?? "–")
                    }
                }
            }
        }
    }
}

struct RawChartView_Previews: PreviewProvider {
    static var api: APIRepresentative = {
        let insight1 = InsightDataTransferObject(
            id: UUID(),
            order: nil, title: "A single Number",
            subtitle: nil,
            signalType: nil,
            uniqueUser: false,
            filters: [:],
            rollingWindowSize: -86000,
            breakdownKey: nil,
            displayMode: .raw,
            data: [
                InsightData(xAxisValue: "2020-11-18 00:00:00+01", yAxisValue: "102")
            ],
            calculatedAt: Date())
        
        let insight2 = InsightDataTransferObject(
            id: UUID(),
            order: nil, title: "2 Numbers",
            subtitle: nil,
            signalType: nil,
            uniqueUser: false,
            filters: [:],
            rollingWindowSize: -86000,
            breakdownKey: nil,
            displayMode: .raw,
            data: [
                InsightData(xAxisValue: "2020-11-19 00:00:00+01", yAxisValue: "100"),
                InsightData(xAxisValue: "2020-11-18 00:00:00+01", yAxisValue: "96")
            ],
            calculatedAt: Date())
        
        let insight3 = InsightDataTransferObject(
            id: UUID(),
            order: nil, title: "Maaaany Entries",
            subtitle: nil,
            signalType: nil,
            uniqueUser: false,
            filters: [:],
            rollingWindowSize: -86000,
            breakdownKey: nil,
            displayMode: .raw,
            data: [
                InsightData(xAxisValue: "Test", yAxisValue: "Omsn"),
                InsightData(xAxisValue: "Test2", yAxisValue: "Omsn2"),
                InsightData(xAxisValue: "Test3", yAxisValue: nil),
                InsightData(xAxisValue: "Test4", yAxisValue: "Omsn4"),
                InsightData(xAxisValue: "Test5", yAxisValue: "Omsn5")
            ],
            calculatedAt: Date())
        
        let api = APIRepresentative()
        api.insightData[insight1.id] = insight1
        api.insightData[insight2.id] = insight2
        api.insightData[insight3.id] = insight3
        
        return api
    }()
    
    static var previews: some View {
        ForEach(Array(api.insightData.keys), id: \.self) { insightID in
            RawChartView(insightDataID: insightID)
                .environmentObject(api)
                .padding()
                .previewLayout(.fixed(width: 400, height: 200))
        }
    }
}
