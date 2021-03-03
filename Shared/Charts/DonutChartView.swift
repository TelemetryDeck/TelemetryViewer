//
//  DonutChartView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 07.10.20.
//

import SwiftUI

struct DonutChartView: View {
    var insightDataID: UUID
    @EnvironmentObject var api: APIRepresentative

    @Binding var topSelectedInsightID: UUID?
    private var isSelected: Bool {
        topSelectedInsightID == insightDataID
    }

    private var insightData: InsightDataTransferObject? { api.insightData[insightDataID] }
    private var chartDataSet: ChartDataSet? {
        guard let insightData = insightData else { return nil }
        return try? ChartDataSet(data: insightData.data)
    }

    private var pieSegments: [PieSegment] {
        var segments = [PieSegment]()
        let total = chartDataSet?.data.reduce(0) { $0 + $1.yAxisValue } ?? 0
        var startAngle = -Double.pi / 2

        for data in chartDataSet?.data ?? [] {
            let amount = .pi * 2 * (data.yAxisValue / total)
            let segment = PieSegment(data: data, startAngle: startAngle, amount: amount)
            segments.append(segment)
            startAngle += amount
        }

        return segments
    }

    @State private var selectedSegmentIndex: Int = 0

    let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        return numberFormatter
    }()

    var body: some View {
        let chart = ZStack {
            ForEach(pieSegments) { segment in
                let selected = pieSegments[selectedSegmentIndex] == segment
                let segmentCount = Double(pieSegments.count)
                let index = pieSegments.firstIndex(of: segment)!
                let opacity = ((segmentCount - Double(index)) / segmentCount) / 2

                segment
                    .stroke(style: StrokeStyle(lineWidth: selected ? 30 : 15))
                    .fill(selected ? Color.accentColor : Color.accentColor.opacity(opacity))
                    .onTapGesture {
                        selectedSegmentIndex = index
                    }
            }
        }

        let legend = VStack(alignment: .center, spacing: -5) {
            if pieSegments.count > 0 {
                Text(pieSegments[selectedSegmentIndex].data.id)
                    .foregroundColor(isSelected ? .cardBackground : .none)
                Text("\(BigNumberFormatter.shortDisplay(for: pieSegments[selectedSegmentIndex].data.yAxisValue))")
                    .font(.system(size: 28, weight: .light, design: .rounded))
                    .foregroundColor(isSelected ? .cardBackground : .none)
            } else {
                HStack {
                    Spacer()
                    Text("No Data Recorded Yet")
                        .font(.footnote)
                        .foregroundColor(isSelected ? .cardBackground : .grayColor)
                    Spacer()
                }
            }
        }

        GeometryReader { reader in
            ZStack(alignment: .center) {
                chart
                legend
            }
            .frame(width: reader.size.width, height: reader.size.height)
        }
        .padding(.bottom)
    }
}

struct DonutChartDataPoint: Identifiable {
    let id: String
    let value: Double

    init(key: String, value: Double) {
        id = key
        self.value = value
    }
}

struct PieSegment: Shape, Identifiable, Equatable {
    static func == (lhs: PieSegment, rhs: PieSegment) -> Bool {
        lhs.id == rhs.id
    }

    let data: ChartDataPoint
    var id: String { data.id }
    var startAngle: Double
    var amount: Double
    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(startAngle, amount) }
        set {
            startAngle = newValue.first
            amount = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) * 0.4
        let center = CGPoint(x: rect.width * 0.5, y: rect.height * 0.5)

        var path = Path()
        path.addRelativeArc(center: center, radius: radius, startAngle: Angle(radians: startAngle), delta: Angle(radians: amount - 0.02))
        return path
    }
}

// struct DonutChartView_Previews: PreviewProvider {
//    static var data: [DonutChartDataPoint] {
//            [
//                DonutChartDataPoint(key: "macOS 10.15 and a Long Name", value: 50),
//                DonutChartDataPoint(key: "macOS 11", value: 64),
//                DonutChartDataPoint(key: "iOS 14.1", value: 20),
//                DonutChartDataPoint(key: "iOS 14.2", value: 64)
//            ]
//        }
//
//    static var previews: some View {
//        DonutChartView(dataPoints: data)
//        .padding()
//        .previewLayout(.fixed(width: 400, height: 400))
//    }
// }
