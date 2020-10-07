//
//  DonutChartView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 07.10.20.
//

import SwiftUI

struct DonutChartDataPoint: Identifiable {
    let id: String
    let value: Double

    init(key: String, value: Double) {
        self.id = key
        self.value = value
    }
}

struct PieSegment: Shape, Identifiable, Equatable {
    static func == (lhs: PieSegment, rhs: PieSegment) -> Bool {
        return lhs.id == rhs.id
    }
    
    let data: DonutChartDataPoint
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

struct DonutChartView: View {
    let pieSegments: [PieSegment]
    @State var selectedSegmentIndex: Int = 0
    
    let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        return numberFormatter
    }()
    
    init(dataPoints: [DonutChartDataPoint]) {
        var segments = [PieSegment]()
        let total = dataPoints.reduce(0) { $0 + $1.value }
        var startAngle = -Double.pi / 2

        for data in dataPoints {
            let amount = .pi * 2 * (data.value / total)
            let segment = PieSegment(data: data, startAngle: startAngle, amount: amount)
            segments.append(segment)
            startAngle += amount
        }

        pieSegments = segments
    }
    
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
                        
                    }.animation(Animation.easeOut.speed(1.5))
            }
        }
        
        let legend = VStack(alignment: .leading, spacing: -5) {
            
            if pieSegments.count > 0 {
                Text(pieSegments[selectedSegmentIndex].data.id)
                Text("\(numberFormatter.string(from: NSNumber(value: pieSegments[selectedSegmentIndex].data.value)) ?? "–")")
                .font(.system(size:48, weight: .black, design: .monospaced))
            } else {
                Text("No Data Recorded Yet")
            }
        }
        .shadow(color: Color("CardBackgroundColor"), radius: 3, x: 0.0, y: 0.0)
        
        
        GeometryReader { reader in
            ZStack(alignment: .trailing) {
                chart.frame(width: reader.size.height, alignment: .trailing)
                legend.frame(width: reader.size.width, alignment: .leading)
            }
            .frame(width: reader.size.width, height: reader.size.height)
        }
    }
}

struct DonutChartView_Previews: PreviewProvider {
    static var data: [DonutChartDataPoint] {
            [
                DonutChartDataPoint(key: "macOS 10.15 and a Long Name", value: 50),
                DonutChartDataPoint(key: "macOS 11", value: 64),
                DonutChartDataPoint(key: "iOS 14.1", value: 20),
                DonutChartDataPoint(key: "iOS 14.2", value: 64)
            ]
        }
    
    static var previews: some View {
        DonutChartView(dataPoints: data)
        .padding()
        .previewLayout(.fixed(width: 400, height: 200))
    }
}
