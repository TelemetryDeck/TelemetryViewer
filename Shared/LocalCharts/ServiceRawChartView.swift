//
//  ServiceRawChartView.swift
//  Telemetry Viewer (iOS)
//
//  Created by Daniel Jilg on 20.07.21.
//

import SwiftUI
import DataTransferObjects
import SwiftUICharts

struct RawChartView: View {
    let chartDataSet: ChartDataSet
    let isSelected: Bool

    var body: some View {
        if chartDataSet.data.count > 2 || chartDataSet.data.first?.xAxisDate == nil {
            RawTableView(insightData: chartDataSet, isSelected: isSelected)
        } else {
            SingleValueView(insightData: chartDataSet, isSelected: isSelected)
                .frame(minWidth: 0,
                       maxWidth: .infinity,
                       minHeight: 0,
                       maxHeight: .infinity,
                       alignment: .topLeading)
                .padding(.bottom)
                .padding(.horizontal)
        }
    }
}

struct ServiceRawChartView: View {
    @EnvironmentObject var insightCalculationService: InsightCalculationService

    let insightID: UUID
    let insightGroupID: UUID
    let appID: UUID

    @Binding var topSelectedInsightID: UUID?
    private var isSelected: Bool {
        topSelectedInsightID == insightID
    }

    var body: some View {
        if let insightData = insightCalculationService.calculationResult(for: insightID, in: insightGroupID, in: appID), !insightData.insightData.data.isEmpty {
            let chartDataSet = insightData.chartDataSet

            if chartDataSet.data.count > 2 || chartDataSet.data.first?.xAxisDate == nil {
                RawTableView(insightData: chartDataSet, isSelected: isSelected)
            } else {
                SingleValueView(insightData: chartDataSet, isSelected: isSelected)
                    .frame(minWidth: 0,
                           maxWidth: .infinity,
                           minHeight: 0,
                           maxHeight: .infinity,
                           alignment: .topLeading)
                    .padding(.bottom)
                    .padding(.horizontal)
            }
        } else {
            Text("No Data").foregroundColor(.grayColor)
        }
    }
}

// struct RawChartView_Previews: PreviewProvider {
//    static var api: APIClient = {
//        let insight1 = DTO.InsightCalculationResult(
//            id: UUID(),
//            order: nil, title: "A single Number",
//            subtitle: nil,
//            signalType: nil,
//            uniqueUser: false,
//            filters: [:],
//            rollingWindowSize: -86000,
//            breakdownKey: nil,
//            displayMode: .raw,
//            isExpanded: false,
//            data: [
//                DTO.InsightData(xAxisValue: "2020-11-21T00:00:00+01:00", yAxisValue: "7762"),
//            ],
//            calculatedAt: Date(), calculationDuration: 1, shouldUseDruid: false
//        )
//
//        let insight2 = DTO.InsightCalculationResult(
//            id: UUID(),
//            order: nil, title: "2 Numbers",
//            subtitle: nil,
//            signalType: nil,
//            uniqueUser: false,
//            filters: [:],
//            rollingWindowSize: -86000,
//            breakdownKey: nil,
//            displayMode: .raw,
//            isExpanded: false,
//            data: [
//                DTO.InsightData(xAxisValue: "2020-11-20T00:00:00+01:00", yAxisValue: "10650"),
//                DTO.InsightData(xAxisValue: "2020-11-21T00:00:00+01:00", yAxisValue: "96"),
//            ],
//            calculatedAt: Date(), calculationDuration: 1, shouldUseDruid: false
//        )
//
//        let insight3 = DTO.InsightCalculationResult(
//            id: UUID(),
//            order: nil, title: "Maaaany Entries",
//            subtitle: nil,
//            signalType: nil,
//            uniqueUser: false,
//            filters: [:],
//            rollingWindowSize: -86000,
//            breakdownKey: nil,
//            displayMode: .raw,
//            isExpanded: false,
//            data: [
//                DTO.InsightData(xAxisValue: "Test", yAxisValue: "Omsn"),
//                DTO.InsightData(xAxisValue: "Test2", yAxisValue: "Omsn2"),
//                DTO.InsightData(xAxisValue: "Test3", yAxisValue: nil),
//                DTO.InsightData(xAxisValue: "Test4", yAxisValue: "Omsn4"),
//                DTO.InsightData(xAxisValue: "Test5", yAxisValue: "Omsn5"),
//            ],
//            calculatedAt: Date(), calculationDuration: 1, shouldUseDruid: false
//        )
//
//        let insight4 = DTO.InsightCalculationResult(
//            id: UUID(),
//            order: nil, title: "2 Numbers, no dates",
//            subtitle: nil,
//            signalType: nil,
//            uniqueUser: false,
//            filters: [:],
//            rollingWindowSize: -86000,
//            breakdownKey: nil,
//            displayMode: .raw,
//            isExpanded: false,
//            data: [
//                DTO.InsightData(xAxisValue: "iOS", yAxisValue: "10650"),
//                DTO.InsightData(xAxisValue: "macOS", yAxisValue: "96"),
//            ],
//            calculatedAt: Date(), calculationDuration: 1, shouldUseDruid: false
//        )
//
//        let api = APIClient()
//        api.insightData[insight1.id] = insight1
//        api.insightData[insight2.id] = insight2
//        api.insightData[insight3.id] = insight3
//        api.insightData[insight4.id] = insight4
//
//        return api
//    }()
//
//    static var previews: some View {
//        ForEach(Array(api.insightData.keys), id: \.self) { insightID in
//            RawChartView(insightDataID: insightID, topSelectedInsightID: .constant(nil))
//                .environmentObject(api)
//                .padding()
//                .previewLayout(.fixed(width: 400, height: 200))
//        }
//    }
// }
