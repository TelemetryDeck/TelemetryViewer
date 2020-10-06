//
//  LineChartView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 29.09.20.
//

import SwiftUI

struct LineChart: Shape {
    var data: [ChartDataPoint]
    var shouldCloseShape: Bool
    
    func path(in rect: CGRect) -> Path {
        guard let firstDate = data.first?.date,
           let lastDate = data.last?.date,
           let lowestValue = data.sorted(by: { $0.value < $1.value }).first?.value,
           let highestValue = data.sorted(by: { $0.value < $1.value }).last?.value
        else { return Path() }
        
        let baselineDateInterval = firstDate.timeIntervalSinceReferenceDate
        let furthestDateInterval = lastDate.timeIntervalSinceReferenceDate - baselineDateInterval
        let numberOfTicks = furthestDateInterval
        
        let xWidthConstant = rect.size.width / CGFloat(numberOfTicks)
        let yHeightConstant = rect.size.height / CGFloat(highestValue)
        
        let bottomRight = CGPoint(x: rect.size.width, y: rect.size.height)
        let bottomleft = CGPoint(x: 0, y: rect.size.height)
        
        let pathPoints: [CGPoint] = {
            var pathPoints: [CGPoint] = []
            for data in self.data {
                let dayOffset = CGFloat(data.date.timeIntervalSinceReferenceDate - baselineDateInterval) * xWidthConstant
                let valueOffset = CGFloat(data.value) * yHeightConstant
                pathPoints.append(CGPoint(x: dayOffset, y: rect.size.height - valueOffset))
            }
            return pathPoints
        }()
        
        var path = Path()
        
        if shouldCloseShape {
            path.move(to: bottomleft)
        } else {
            if let firstPoint = pathPoints.first {
                path.move(to: firstPoint)
            }
        }
            
        for point in pathPoints {
            path.addLine(to: point)
        }
        
        if shouldCloseShape {
            path.addLine(to: bottomRight)
            path.addLine(to: bottomleft)
            
            if let firstPoint = pathPoints.first {
                path.addLine(to: firstPoint)
            }
        }
        
        return path
    }
}

struct LineChartView: View {
    var data: [ChartDataPoint]
    
    var body: some View {
        ZStack {
            LineChart(data: data, shouldCloseShape: true).fill(Color.blue.opacity(0.2))
            LineChart(data: data, shouldCloseShape: false).stroke(Color.blue.opacity(0.5), style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
        }
    }
    
    func yHeightConstant(_ height: CGFloat, range: Double) -> CGFloat {
        height / CGFloat(range)
    }
    
    func xWidthConstant(_ width: CGFloat, count: Int) -> CGFloat {
        width / CGFloat(count)
    }
    
    func valueOffset(_ temperature: Double, valueHeight: CGFloat) -> CGFloat {
        CGFloat(temperature) * valueHeight
    }
    
}

struct LineChartView_Previews: PreviewProvider {
    static var previews: some View {
        LineChartView(data: [
            .init(date: Date(timeIntervalSinceNow: -3600*24*9), value: 1),
            .init(date: Date(timeIntervalSinceNow: -3600*24*8), value: 2),
            .init(date: Date(timeIntervalSinceNow: -3600*24*7), value: 3),
            .init(date: Date(timeIntervalSinceNow: -3600*24*6), value: 4),
            .init(date: Date(timeIntervalSinceNow: -3600*24*4), value: 3),
            .init(date: Date(timeIntervalSinceNow: -3600*24*3), value: 6),
            .init(date: Date(timeIntervalSinceNow: -3600*24*2), value: 5),
            .init(date: Date(timeIntervalSinceNow: -3600*24*1), value: 8),
        ])
        .padding()
        .previewLayout(.fixed(width: 400, height: 400))
    }
}

