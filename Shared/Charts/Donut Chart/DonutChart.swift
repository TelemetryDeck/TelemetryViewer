//
//  DonutChart.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 23.04.21.
//

import SwiftUI
import TelemetryModels

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

