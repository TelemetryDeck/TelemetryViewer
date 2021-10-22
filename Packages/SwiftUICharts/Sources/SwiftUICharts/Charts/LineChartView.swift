//
//  LineChartView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 29.09.20.
//

import SwiftUI

public struct LineChart: View {
    public init(chartDataSet: ChartDataSet, isSelected: Bool) {
        self.chartDataSet = chartDataSet
        self.isSelected = isSelected
    }
    
    let chartDataSet: ChartDataSet
    let isSelected: Bool

    @State var selectedChartDataPoint: ChartDataPoint? = nil
    
    private var hoverLayer: some View {
        HStack(spacing: 0) {
            ForEach(Array(chartDataSet.data.dropFirst())) { dataPoint in
                let isCurrent = chartDataSet.isCurrentPeriod(dataPoint)
                
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isCurrent ? .accentColor.opacity(0.15) : (selectedChartDataPoint == dataPoint ? Color.grayColor.opacity(0.15) : Color.clear))
                    .onHover { hovering in
                        withAnimation {
                            selectedChartDataPoint = hovering ? dataPoint : nil
                        }
                    }
            }
        }
    }

    public var body: some View {
        VStack {
            HStack {
                ZStack(alignment: .topTrailing) {
                    LineChartShape(data: chartDataSet, shouldCloseShape: true, selectedChartDataPoint: nil).fill(
                        LinearGradient(gradient: Gradient(colors: [Color.accentColor.opacity(0.2), Color.accentColor.opacity(0.0)]), startPoint: .top, endPoint: .bottom)
                    )
                    LineChartShape(data: chartDataSet, shouldCloseShape: false, selectedChartDataPoint: selectedChartDataPoint).stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    
                    if selectedChartDataPoint != nil {
                        ChartHoverLabel(dataEntry: selectedChartDataPoint!, interval: chartDataSet.groupBy ?? .day)
                            .padding()
                    }
                    
                    hoverLayer
                }

                if let lastValue = chartDataSet.data.last?.yAxisValue {
                    ChartRangeView(lastValue: Double(lastValue), chartDataSet: chartDataSet, isSelected: isSelected)
                }
            }

            ChartBottomView(insightData: chartDataSet, isSelected: isSelected)
                .padding(.trailing, 35)
                .padding(.leading)
        }
        .font(.footnote)
        .foregroundColor(Color.grayColor)
        .padding(.bottom)
    }
}

struct LineChartShape: Shape {
    var data: ChartDataSet
    var shouldCloseShape: Bool
    let selectedChartDataPoint: ChartDataPoint?

    func path(in rect: CGRect) -> Path {
        let numberOfTicks = data.data.count

        let xWidthConstant = rect.size.width / CGFloat(numberOfTicks - 1)
        let yHeightConstant = rect.size.height / CGFloat(data.highestValue)

        let bottomRight = CGPoint(x: rect.size.width, y: rect.size.height)
        let bottomLeft = CGPoint(x: 0, y: rect.size.height)
        
        var selectedPoint: CGPoint?

        let pathPoints: [CGPoint] = {
            var pathPoints: [CGPoint] = []
            for (index, data) in self.data.data.enumerated() {
                let dayOffset = xWidthConstant * CGFloat(index)
                let valueOffset = CGFloat(data.yAxisValue ?? 0) * yHeightConstant
                let point = CGPoint(x: dayOffset, y: rect.size.height - valueOffset)
                pathPoints.append(point)
                
                if selectedChartDataPoint == data {
                    selectedPoint = point
                }
            }
            return pathPoints
        }()

        var path = Path()

        if shouldCloseShape {
            path.move(to: bottomLeft)
        } else {
            if let firstPoint = pathPoints.first {
                path.move(to: firstPoint)
            }
        }

        for point in pathPoints {
            path.addLine(to: point)
        }
        
        if !shouldCloseShape, let selectedPoint = selectedPoint {
            path.addEllipse(in: CGRect(x: selectedPoint.x - 2, y: selectedPoint.y - 2, width: 4, height: 4), transform: .identity)
            path.addEllipse(in: CGRect(x: selectedPoint.x - 3, y: selectedPoint.y - 3, width: 6, height: 6), transform: .identity)
        }

        if shouldCloseShape {
            path.addLine(to: bottomRight)
            path.addLine(to: bottomLeft)

            if let firstPoint = pathPoints.first {
                path.addLine(to: firstPoint)
            }
        }

        return path
    }
}

let mockChartDataPoints: [ChartDataPoint] = [
]

struct LineChartView_Previews: PreviewProvider {
    static var previews: some View {
        

        let chartDataSet = ChartDataSet(data: mockChartDataPoints, groupBy: .day)

        LineChart(chartDataSet: chartDataSet, isSelected: false)
            .padding()
            .previewLayout(.fixed(width: 400, height: 200))
    }
}
