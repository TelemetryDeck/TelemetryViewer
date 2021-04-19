//
//  DonutChartView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 07.10.20.
//

import SwiftUI
import TelemetryModels

struct DonutChartView: View {
    var insightDataID: UUID
    @EnvironmentObject var api: APIRepresentative
    
    @Binding var topSelectedInsightID: UUID?
    private var isSelected: Bool {
        topSelectedInsightID == insightDataID
    }
    
    private var insightData: InsightDTO? { api.insightData[insightDataID] }
    private var chartDataSet: ChartDataSet? {
        guard let insightData = insightData else { return nil }
        return try? ChartDataSet(data: insightData.data)
    }
    
    var body: some View {
        if let chartDataSet = chartDataSet {
            DonutChartContainer(chartDataSet: chartDataSet)
                .padding(.bottom)
                .padding(.horizontal)
        } else {
            Text("No Data")
        }
    }
}



struct PieSegment: Shape, Identifiable, Equatable {
    static func == (lhs: PieSegment, rhs: PieSegment) -> Bool {
        lhs.id == rhs.id
    }
    
    let data: ChartDataPoint
    var id: Int
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

// MARK: - Preview
struct DonutChartView_Previews: PreviewProvider {
    static var data: ChartDataSet = try! ChartDataSet(
        data: [
            InsightData(xAxisValue: "Cool Users", yAxisValue: "859"),
            InsightData(xAxisValue: "Enthusiastic Users", yAxisValue: "515"),
            InsightData(xAxisValue: "Happy Users", yAxisValue: "321"),
            InsightData(xAxisValue: "Interested Users", yAxisValue: "214"),
            InsightData(xAxisValue: "Encouraged Users", yAxisValue: "145"),
            InsightData(xAxisValue: "Disinterested Users", yAxisValue: "13"),
            InsightData(xAxisValue: "Unhappy Users", yAxisValue: "4"),
            InsightData(xAxisValue: "Angry Users", yAxisValue: "2")
        ])
    
    static var previews: some View {
        
        DonutChartContainer(chartDataSet: data)
            .padding()
            .previewLayout(.fixed(width: 285, height: 165))
    }
}

struct DonutChartContainer: View {
    @State private var selectedSegmentIndex: Int?
    let chartDataSet: ChartDataSet
    
    let maxEntries: Int = 5
    
    var body: some View {
        HStack {
            DonutLegend(selectedSegmentIndex: $selectedSegmentIndex, chartDataSet: chartDataSet, maxEntries: maxEntries)
            DonutChart(selectedSegmentIndex: $selectedSegmentIndex, chartDataSet: chartDataSet, maxEntries: maxEntries)
        }
    }
}

struct DonutLegendEntry: View {
    let value: DonutLegendEntryValue
    let color: Color
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Circle()
                .fill(isSelected ? .cardBackground : color)
                .frame(maxWidth: 10, maxHeight: 10)
            Text(value.xAxisValue)
                .foregroundColor(isSelected ? .cardBackground : .primary)
            Spacer()
            SmallValueView(value: value.yAxisValue, shouldFormatBigNumbers: true)
                .foregroundColor(isSelected ? .cardBackground : .primary)
                .smallValueStyle()
            
        }
        .subtitleStyle()
    }
}

struct DonutLegendEntryValue: Identifiable {
    let id: Int
    let xAxisValue: String
    let yAxisValue: Double
}

struct DonutLegend: View {
    @Binding var selectedSegmentIndex: Int?
    let chartDataSet: ChartDataSet
    let maxEntries: Int
    
    private var otherSum: Double {
        guard chartDataSet.data.count > maxEntries else { return 0 }
        
        let missingEntriesCount = chartDataSet.data.count - maxEntries
        let missingEntries = Array(chartDataSet.data.suffix(missingEntriesCount))
        return missingEntries.map { $0.yAxisValue }.reduce(Double(0), +)
    }
    
    private var donutLegendEntryValues: [DonutLegendEntryValue] {
        var values: [DonutLegendEntryValue] = []
        
        for (index, data) in chartDataSet.data.prefix(maxEntries).enumerated() {
            let value = DonutLegendEntryValue(id: index, xAxisValue: data.xAxisValue, yAxisValue: data.yAxisValue)
            values.append(value)
        }
        
        return values
    }
    
    func opacity(segmentCount: Double, index: Int) -> Double {
        (Double(1) / segmentCount) * (segmentCount - Double(index))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(donutLegendEntryValues) { value in
                DonutLegendEntry(value: value, color: Color.telemetryOrange.opacity(opacity(segmentCount: Double(donutLegendEntryValues.count), index: value.id)), isSelected: selectedSegmentIndex == value.id)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(selectedSegmentIndex == value.id ? Color.accentColor : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
                    .onTapGesture {
                        selectedSegmentIndex = value.id
                    }
            }
            
            if chartDataSet.data.count > maxEntries {
                DonutLegendEntry(value: DonutLegendEntryValue(id: -1, xAxisValue: "Other", yAxisValue: otherSum), color: .grayColor, isSelected: selectedSegmentIndex ?? -1 > maxEntries)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(selectedSegmentIndex ?? -1 > maxEntries ? Color.grayColor.opacity(0.7) : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
            }
        }
    }
}

struct DonutChart: View {
    @Binding var selectedSegmentIndex: Int?
    let chartDataSet: ChartDataSet
    let maxEntries: Int
    
    private var pieSegments: [PieSegment] {
        var segments = [PieSegment]()
        let total = chartDataSet.data.reduce(0) { $0 + $1.yAxisValue }
        var startAngle = -Double.pi / 2
        
        for (index, data) in chartDataSet.data.enumerated() {
            let amount = .pi * 2 * (data.yAxisValue / total)
            let segment = PieSegment(data: data, id: index, startAngle: startAngle, amount: amount)
            segments.append(segment)
            startAngle += amount
        }
        
        return segments
    }
    
    func opacity(segmentCount: Double, index: Int) -> Double {
        (Double(1) / segmentCount) * (segmentCount - Double(index))
    }
    
    var body: some View {
        ZStack {
            ForEach(pieSegments) { segment in
                let selected = selectedSegmentIndex != nil ? pieSegments[selectedSegmentIndex!] == segment : false
                let segmentCount = Double(pieSegments.count)
                let index = segment.id
                let opacity = opacity(segmentCount: segmentCount, index: index)
                
                segment
                    .stroke(style: StrokeStyle(lineWidth: selected ? 40 : 25))
                    .fill(selected ? Color.accentColor : Color.accentColor.opacity(opacity))
                    .onTapGesture {
                        selectedSegmentIndex = index
                    }
            }
            .animation(.easeOut)
        }
    }
}
