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

    @Binding var topSelectedInsightID: UUID?
    private var isSelected: Bool {
        return topSelectedInsightID == insightDataID
    }

    private var insightData: InsightDataTransferObject? { api.insightData[insightDataID] }

    var body: some View {
        if let insightData = insightData, !insightData.data.isEmpty {
            if insightData.data.count > 2 {
                RawTableView(insightData: insightData, isSelected: isSelected)
            } else {
                SingleValueView(insightData: insightData, isSelected: isSelected)
                    .frame(minWidth: 0,
                           maxWidth: .infinity,
                           minHeight: 0,
                           maxHeight: .infinity,
                           alignment: .topLeading
                            )
                    .padding(.bottom)
                    .padding(.horizontal)
            }
        } else {
            Text("No Data").foregroundColor(.grayColor)
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
                InsightData(xAxisValue: "2020-11-21T00:00:00+01:00", yAxisValue: "102"),
            ],
            calculatedAt: Date(), calculationDuration: 1
        )

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
                InsightData(xAxisValue: "2020-11-20T00:00:00+01:00", yAxisValue: "10650"),
                InsightData(xAxisValue: "2020-11-21T00:00:00+01:00", yAxisValue: "96"),
            ],
            calculatedAt: Date(), calculationDuration: 1
        )

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
                InsightData(xAxisValue: "Test5", yAxisValue: "Omsn5"),
            ],
            calculatedAt: Date(), calculationDuration: 1
        )

        let api = APIRepresentative()
        api.insightData[insight1.id] = insight1
        api.insightData[insight2.id] = insight2
        api.insightData[insight3.id] = insight3

        return api
    }()

    static var previews: some View {
        ForEach(Array(api.insightData.keys), id: \.self) { insightID in
            RawChartView(insightDataID: insightID, topSelectedInsightID: .constant(nil))
                .environmentObject(api)
                .padding()
                .previewLayout(.fixed(width: 400, height: 200))
        }
    }
}

struct SingleValueView: View {
    var insightData: InsightDataTransferObject

    let isSelected: Bool

    let percentageFormatter: NumberFormatter = {
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        return percentageFormatter
    }()

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(insightData.data.last?.yAxisString ?? "0")
                    .font(.system(size: 28, weight: .light, design: .rounded))
                    .foregroundColor(isSelected ? .cardBackground : .none)

                xAxisDefinition(insightData: insightData.data.last!, style: .date)
                    .foregroundColor(isSelected ? .cardBackground : .grayColor)
                    .font(.system(size: 12, weight: .light, design: .default))
            }
            .padding(.bottom, insightData.data.count > 1 ? nil : 0)

            Spacer()

            if insightData.data.count > 1 {
                secondaryText()
                    .foregroundColor(isSelected ? .cardBackground : .grayColor)
                    .font(.system(size: 12, weight: .light, design: .default))
            }
        }
    }

    func xAxisDefinition(insightData: InsightData, style: Text.DateStyle) -> Text {
        if let date = insightData.xAxisDate {
            return Text(date, style: style)
        }

        return Text(insightData.xAxisValue)
    }

    func percentageString(from percentage: Double) -> String {
        let percentageNumber = NSNumber(value: percentage)
        let percentageChangeSymbol: String

        if percentage > 0 {
            percentageChangeSymbol = "▵"
        } else if percentage < 0 {
            percentageChangeSymbol = "▽"
        } else {
            percentageChangeSymbol = ""
        }

        if percentageNumber.doubleValue.isNaN {
            return "No Change"
        }

        return "\(percentageChangeSymbol)\(percentageFormatter.string(from: percentageNumber)!)"
    }

    func secondaryText() -> Text {
        guard insightData.data.count > 1 else { return Text("") }
        let previousData = insightData.data[0]

        guard let currentValue = insightData.data[1].yAxisNumber, let previousValue = insightData.data[0].yAxisNumber else { return xAxisDefinition(insightData: insightData.data[0], style: .date) }

        let percentage: Double = (currentValue.doubleValue - previousValue.doubleValue) / previousValue.doubleValue

        return Text("\(percentageString(from: percentage)) compared to ") + xAxisDefinition(insightData: previousData, style: .date) + Text(" (\(previousData.yAxisString))")
    }
}

struct RawTableView: View {
    var insightData: InsightDataTransferObject

    let isSelected: Bool

    private let columns = [
        GridItem(.flexible(maximum: 200), spacing: nil, alignment: .leading),
        GridItem(.flexible(), spacing: nil, alignment: .trailing),
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(insightData.data, id: \.xAxisValue) { dataRow in
                    Group {
                        Group {
                            if let xAxisDate = dataRow.xAxisDate {
                                HStack {
                                    Text(xAxisDate, style: .date)
                                        .foregroundColor(isSelected ? .cardBackground : .none)

                                    if insightData.groupBy == .hour {
                                        Text(xAxisDate, style: .time)
                                            .foregroundColor(isSelected ? .cardBackground : .none)
                                    }
                                }
                            } else {
                                Text(dataRow.xAxisValue)
                                    .foregroundColor(isSelected ? .cardBackground : .none)
                            }
                        }
                        .font(.footnote)
                        .foregroundColor(isSelected ? .cardBackground : .grayColor)

                        Text(dataRow.yAxisString)
                            .font(.system(size: 28, weight: .light, design: .rounded))
                            .foregroundColor(isSelected ? .cardBackground : .none)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
