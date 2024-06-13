//
//  MockData.swift
//  File
//
//  Created by Charlotte Böhm on 05.10.21.
//

import DataTransferObjects
import Foundation

private func generateResultData(type: DTOv2.Insight.InsightType, granularity: QueryGranularity) -> [DTOv2.InsightCalculationResultRow] {
    var returnValue: [DTOv2.InsightCalculationResultRow] = []

    switch type {
    case .timeseries:
        var previousValue: Int64 = 7000
        for date in (granularity == .day) ? dailyDates : monthlyDates {
            previousValue += Int64.random(in: 0 ..< 100)
            returnValue.append(DTOv2.InsightCalculationResultRow(xAxisValue: date, yAxisValue: previousValue))
        }
    case .topN:
        for value in breakdownKeyValues {
            returnValue.append(DTOv2.InsightCalculationResultRow(xAxisValue: value, yAxisValue: Int64.random(in: 1000 ..< 10000)))
        }
    default:
        returnValue = []
    }

    return returnValue
}

private let monthlyDates = [
    "2021-08-01T00:00:00.000Z",
    "2021-09-01T00:00:00.000Z",
    "2021-10-01T00:00:00.000Z",
]

private let dailyDates = [
    "2021-08-31T00:00:00.000Z",
    "2021-09-01T00:00:00.000Z",
    "2021-09-02T00:00:00.000Z",
    "2021-09-03T00:00:00.000Z",
    "2021-09-04T00:00:00.000Z",
    "2021-09-05T00:00:00.000Z",
    "2021-09-06T00:00:00.000Z",
    "2021-09-07T00:00:00.000Z",
    "2021-09-08T00:00:00.000Z",
    "2021-09-09T00:00:00.000Z",
    "2021-09-10T00:00:00.000Z",
    "2021-09-11T00:00:00.000Z",
    "2021-09-12T00:00:00.000Z",
    "2021-09-13T00:00:00.000Z",
    "2021-09-14T00:00:00.000Z",
    "2021-09-15T00:00:00.000Z",
    "2021-09-16T00:00:00.000Z",
    "2021-09-17T00:00:00.000Z",
    "2021-09-18T00:00:00.000Z",
    "2021-09-19T00:00:00.000Z",
    "2021-09-20T00:00:00.000Z",
    "2021-09-21T00:00:00.000Z",
    "2021-09-22T00:00:00.000Z",
    "2021-09-23T00:00:00.000Z",
    "2021-09-24T00:00:00.000Z",
    "2021-09-25T00:00:00.000Z",
    "2021-09-26T00:00:00.000Z",
    "2021-09-27T00:00:00.000Z",
    "2021-09-28T00:00:00.000Z",
    "2021-09-29T00:00:00.000Z",
    "2021-09-30T00:00:00.000Z",
    "2021-10-01T00:00:00.000Z",
    "2021-10-02T00:00:00.000Z",
    "2021-10-03T00:00:00.000Z",
    "2021-10-04T00:00:00.000Z",
    "2021-10-05T00:00:00.000Z",
]

private let breakdownKeyValues = [
    "iPhone XR",
    "iPhone 11",
    "iPhone 12 Pro Max",
    "iPhone SE 2nd Gen",
    "iPhone XS Max Global",
    "iPhone 11 Pro",
    "iPhone 11 Pro Max",
]

let insightCalculationResults = [
    DTOv2.InsightCalculationResult(
        id: UUID(uuidString: "36ECF853-7651-40C1-BABF-6ED06324C16A")!,
        insight: DTOv2.Insight(
            id: UUID(uuidString: "36ECF853-7651-40C1-BABF-6ED06324C16A")!,
            groupID: UUID(uuidString: "D0DAB332-3C26-46BE-98EF-D828587292D0")!,
            order: 0,
            title: "Active Users by Month",
            type: .timeseries,
            accentColor: nil,
            customQuery: nil,
            signalType: nil,
            uniqueUser: true,
            filters: [:],
            breakdownKey: nil,
            groupBy: .month,
            displayMode: .raw,
            isExpanded: false,
            lastRunTime: 0.47125601768493652,
            lastRunAt: Date(timeIntervalSince1970: 1_633_425_036)
        ),
        data: generateResultData(type: .timeseries, granularity: .month),
        calculatedAt: Date(),
        calculationDuration: 0.47125601768493652
    ),

    DTOv2.InsightCalculationResult(
        id: UUID(uuidString: "C8DB1A2A-40DE-40F8-A4DD-741F3D97F9F3")!,
        insight: DTOv2.Insight(
            id: UUID(uuidString: "C8DB1A2A-40DE-40F8-A4DD-741F3D97F9F3")!,
            groupID: UUID(uuidString: "D0DAB332-3C26-46BE-98EF-D828587292D0")!,
            order: 0,
            title: "Signals by Day",
            type: .timeseries,
            accentColor: "C2CBCE",
            customQuery: nil,
            signalType: nil,
            uniqueUser: true,
            filters: [:],
            breakdownKey: nil,
            groupBy: .day,
            displayMode: .lineChart,
            isExpanded: false,
            lastRunTime: 0.52053999900817871,
            lastRunAt: Date(timeIntervalSince1970: 1_633_425_036)
        ),
        data: generateResultData(type: .timeseries, granularity: .day),
        calculatedAt: Date(),
        calculationDuration: 0.52053999900817871
    ),

    DTOv2.InsightCalculationResult(
        id: UUID(uuidString: "025B8420-E688-4826-B3A7-8F5497C277EE")!,
        insight: DTOv2.Insight(
            id: UUID(uuidString: "025B8420-E688-4826-B3A7-8F5497C277EE")!,
            groupID: UUID(uuidString: "D0DAB332-3C26-46BE-98EF-D828587292D0")!,
            order: 0,
            title: "Custom Query Insight",
            type: .customQuery,
            accentColor: "E0A4C3",
            customQuery: nil,
            signalType: nil,
            uniqueUser: false,
            filters: [:],
            breakdownKey: nil,
            groupBy: .day,
            displayMode: .barChart,
            isExpanded: false,
            lastRunTime: 0.52057492733001709,
            lastRunAt: Date(timeIntervalSince1970: 1_633_425_036)
        ),
        data: generateResultData(type: .timeseries, granularity: .day),
        calculatedAt: Date(),
        calculationDuration: 0.52057492733001709
    ),

    DTOv2.InsightCalculationResult(
        id: UUID(uuidString: "9ECA2C34-58B1-4532-B35D-8DC04C796778")!,
        insight: DTOv2.Insight(
            id: UUID(uuidString: "9ECA2C34-58B1-4532-B35D-8DC04C796778")!,
            groupID: UUID(uuidString: "D0DAB332-3C26-46BE-98EF-D828587292D0")!,
            order: 0,
            title: "Device Type Breakdown",
            type: .topN,
            accentColor: "F38630",
            customQuery: nil,
            signalType: nil,
            uniqueUser: false,
            filters: [:],
            breakdownKey: "modelName",
            groupBy: nil,
            displayMode: .pieChart,
            isExpanded: false,
            lastRunTime: 0.60822093486785889,
            lastRunAt: Date(timeIntervalSince1970: 1_633_425_036)
        ),
        data: generateResultData(type: .topN, granularity: .all),
        calculatedAt: Date(),
        calculationDuration: 0.60822093486785889
    ),

    DTOv2.InsightCalculationResult(
        id: UUID(uuidString: "6106D79C-215C-4EF7-9F10-BF9DF6344C1C")!,
        insight: DTOv2.Insight(
            id: UUID(uuidString: "6106D79C-215C-4EF7-9F10-BF9DF6344C1C")!,
            groupID: UUID(uuidString: "D0DAB332-3C26-46BE-98EF-D828587292D0")!,
            order: 0,
            title: "OS Breakdown",
            type: .topN,
            accentColor: "EB2727",
            customQuery: nil,
            signalType: nil,
            uniqueUser: false,
            filters: ["platform": "iOS"],
            breakdownKey: "systemVersion",
            groupBy: nil,
            displayMode: .pieChart,
            isExpanded: false,
            lastRunTime: 0.60810494422912598,
            lastRunAt: Date(timeIntervalSince1970: 1_633_425_036)
        ),
        data: generateResultData(type: .topN, granularity: .all),
        calculatedAt: Date(),
        calculationDuration: 0.60810494422912598
    ),

    DTOv2.InsightCalculationResult(
        id: UUID(uuidString: "0EFDB5F0-446D-4468-95CB-2D5CD75AF8C8")!,
        insight: DTOv2.Insight(
            id: UUID(uuidString: "0EFDB5F0-446D-4468-95CB-2D5CD75AF8C8")!,
            groupID: UUID(uuidString: "D0DAB332-3C26-46BE-98EF-D828587292D0")!,
            order: 1,
            title: "Daily Active Users",
            type: .timeseries,
            accentColor: "E0E4CC",
            customQuery: nil,
            signalType: nil,
            uniqueUser: true,
            filters: ["platform": "iOS"],
            breakdownKey: nil,
            groupBy: .day,
            displayMode: .barChart,
            isExpanded: true,
            lastRunTime: 0.6224219799041748,
            lastRunAt: Date(timeIntervalSince1970: 1_633_425_036)
        ),
        data: generateResultData(type: .timeseries, granularity: .day),
        calculatedAt: Date(),
        calculationDuration: 0.6224219799041748
    ),
]
