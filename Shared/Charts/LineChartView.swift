//
//  LineChartView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 29.09.20.
//

import SwiftUI

struct LineChart: Shape {
    var data: ChartData
    var shouldCloseShape: Bool
    
    func path(in rect: CGRect) -> Path {
        let baselineDateInterval = data.firstDate.timeIntervalSinceReferenceDate
        let furthestDateInterval = data.lastDate.timeIntervalSinceReferenceDate - baselineDateInterval
        let numberOfTicks = furthestDateInterval
        
        let xWidthConstant = rect.size.width / CGFloat(numberOfTicks)
        let yHeightConstant = rect.size.height / CGFloat(data.highestValue)
        
        let bottomRight = CGPoint(x: rect.size.width, y: rect.size.height)
        let bottomleft = CGPoint(x: 0, y: rect.size.height)
        
        let pathPoints: [CGPoint] = {
            var pathPoints: [CGPoint] = []
            for data in self.data.data {
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
    var data: ChartData
    
    var body: some View {
        VStack {
            HStack {
                ZStack {
                    LineChart(data: data, shouldCloseShape: true).fill(
                        LinearGradient(gradient: Gradient(colors: [Color.accentColor.opacity(0.2), Color.accentColor.opacity(0.0)]), startPoint: .top, endPoint: .bottom)
                    )
                    LineChart(data: data, shouldCloseShape: false).stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                }
                
  
                    GeometryReader { reader in
                        let lastValue = data.data.last!.value
                        let percentage = 1 - (lastValue / (data.highestValue - data.lowestValue))
                            
//                        ZStack {
//                            
//                            if lastValue != data.lowestValue {
//                                Text(data.lowestValue.stringValue)
//                                    .position(x: 10, y: reader.size.height)
//                            }
//                            
//                            if lastValue != data.highestValue {
//                                Text(data.highestValue.stringValue)
//                                    .position(x: 10, y: 0)
//                            }
//                            
//                            Text(lastValue.stringValue)
//                                .frame(width: 30)
//                                .multilineTextAlignment(.trailing)
//                                .foregroundColor(.accentColor)
//                                .position(x: 10, y: reader.size.height * CGFloat(percentage))
//                        }
                    }
                    .frame(width: 30)
            }
            
            
            HStack {
                Text(data.firstDate, style: .date)
                Spacer()
                Text(data.lastDate, style: .date)
                    .padding(.trailing, 35)
            }
            
            
        }
        .font(.footnote)
        .foregroundColor(Color.grayColor)
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
        let chartData = try! ChartData(data: [
            .init(date: Date(timeIntervalSinceNow: -3600*24*9), value: 1),
            .init(date: Date(timeIntervalSinceNow: -3600*24*8), value: 20),
            .init(date: Date(timeIntervalSinceNow: -3600*24*7), value: 30),
            .init(date: Date(timeIntervalSinceNow: -3600*24*6), value: 40),
            .init(date: Date(timeIntervalSinceNow: -3600*24*4), value: 30),
            .init(date: Date(timeIntervalSinceNow: -3600*24*3), value: 80),
            .init(date: Date(timeIntervalSinceNow: -3600*24*2), value: 24),
            .init(date: Date(timeIntervalSinceNow: -3600*24*1), value: 60),
        ])
        
        LineChartView(data: chartData)
        .padding()
        .previewLayout(.fixed(width: 400, height: 200))
    }
}

