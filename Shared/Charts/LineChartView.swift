//
//  LineChartView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 29.09.20.
//

import SwiftUI

struct LineChartShape: Shape {
    var data: ChartDataSet
    var shouldCloseShape: Bool
    let selectedChartDataPoint: ChartDataPoint?

    func path(in rect: CGRect) -> Path {
        let numberOfTicks = data.data.count

        let xWidthConstant = rect.size.width / CGFloat(numberOfTicks - 1)
        let yHeightConstant = rect.size.height / CGFloat(data.highestValue)

        let bottomRight = CGPoint(x: rect.size.width, y: rect.size.height)
        let bottomleft = CGPoint(x: 0, y: rect.size.height)
        
        var selectedPoint: CGPoint?

        let pathPoints: [CGPoint] = {
            var pathPoints: [CGPoint] = []
            for (index, data) in self.data.data.enumerated() {
                let dayOffset = xWidthConstant * CGFloat(index)
                let valueOffset = CGFloat(data.yAxisDouble ?? 0) * yHeightConstant
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
            path.move(to: bottomleft)
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
            path.addEllipse(in: CGRect(x: selectedPoint.x - 4, y: selectedPoint.y - 4, width: 8, height: 8), transform: .identity)
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

struct LineChart: View {
    let chartDataSet: ChartDataSet
    let isSelected: Bool

    @State var selectedChartDataPoint: ChartDataPoint? = nil

    var body: some View {
        VStack {
            HStack {
                ZStack(alignment: .topTrailing) {
                    LineChartShape(data: chartDataSet, shouldCloseShape: true, selectedChartDataPoint: nil).fill(
                        LinearGradient(gradient: Gradient(colors: [Color.accentColor.opacity(0.2), Color.accentColor.opacity(0.0)]), startPoint: .top, endPoint: .bottom)
                    )
                    LineChartShape(data: chartDataSet, shouldCloseShape: false, selectedChartDataPoint: selectedChartDataPoint).stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    
                    HStack(spacing: 0) {
                        ForEach(chartDataSet.data) { dataPoint in
                            Rectangle()
                                .fill(Color.clear)
                                .onHover { hovering in
                                    withAnimation {
                                        selectedChartDataPoint = hovering ? dataPoint : nil
                                    }
                                }
                        }
                    }
                    
                    if selectedChartDataPoint != nil {
                        ChartHoverLabel(dataEntry: selectedChartDataPoint!, interval: chartDataSet.groupBy ?? .day)
                            .padding()
                    }
                }

                if let lastValue = chartDataSet.data.last?.yAxisDouble {
                    ChartRangeView(lastValue: lastValue, chartDataSet: chartDataSet, isSelected: isSelected)
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

struct LineChartView: View {
    @EnvironmentObject var insightCalculationService: InsightCalculationService

    let insightID: UUID
    let insightGroupID: UUID
    let appID: UUID

    @Binding var topSelectedInsightID: UUID?
    private var isSelected: Bool {
        topSelectedInsightID == insightID
    }

    var body: some View {
        if let insightData = insightCalculationService.insightData(for: insightID, in: insightGroupID, in: appID) {
            let chartDataSet = ChartDataSet(data: insightData.data)
            LineChart(chartDataSet: chartDataSet, isSelected: isSelected)
        } else {
            Text("Cannot display this as a Chart")
        }
    }
}

struct LineChartView_Previews: PreviewProvider {
    static var previews: some View {
        let chartDataPoints: [ChartDataPoint] = [
            ChartDataPoint(
                xAxisValue: "2021-05-31T00:00:00.000Z",
                yAxisValue: "249"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-01T00:00:00.000Z",
                yAxisValue: "205"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-02T00:00:00.000Z",
                yAxisValue: "216"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-03T00:00:00.000Z",
                yAxisValue: "180"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-04T00:00:00.000Z",
                yAxisValue: "205"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-05T00:00:00.000Z",
                yAxisValue: "195"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-06T00:00:00.000Z",
                yAxisValue: "213"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-07T00:00:00.000Z",
                yAxisValue: "216"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-08T00:00:00.000Z",
                yAxisValue: "305"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-09T00:00:00.000Z",
                yAxisValue: "195"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-10T00:00:00.000Z",
                yAxisValue: "204"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-11T00:00:00.000Z",
                yAxisValue: "220"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-12T00:00:00.000Z",
                yAxisValue: "218"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-13T00:00:00.000Z",
                yAxisValue: "225"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-14T00:00:00.000Z",
                yAxisValue: "219"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-15T00:00:00.000Z",
                yAxisValue: "224"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-16T00:00:00.000Z",
                yAxisValue: "200"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-17T00:00:00.000Z",
                yAxisValue: "220"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-18T00:00:00.000Z",
                yAxisValue: "224"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-19T00:00:00.000Z",
                yAxisValue: "172"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-20T00:00:00.000Z",
                yAxisValue: "128"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-21T00:00:00.000Z",
                yAxisValue: "190"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-22T00:00:00.000Z",
                yAxisValue: "150"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-23T00:00:00.000Z",
                yAxisValue: "199"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-24T00:00:00.000Z",
                yAxisValue: "111"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-25T00:00:00.000Z",
                yAxisValue: "196"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-26T00:00:00.000Z",
                yAxisValue: "171"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-27T00:00:00.000Z",
                yAxisValue: "224"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-28T00:00:00.000Z",
                yAxisValue: "162"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-29T00:00:00.000Z",
                yAxisValue: "177"
            ),
            ChartDataPoint(
                xAxisValue: "2021-06-30T00:00:00.000Z",
                yAxisValue: "210"
            ),
            ChartDataPoint(
                xAxisValue: "2021-07-01T00:00:00.000Z",
                yAxisValue: "185"
            ),
            ChartDataPoint(
                xAxisValue: "2021-07-02T00:00:00.000Z",
                yAxisValue: "141"
            ),
            ChartDataPoint(
                xAxisValue: "2021-07-03T00:00:00.000Z",
                yAxisValue: "173"
            ),
            ChartDataPoint(
                xAxisValue: "2021-07-04T00:00:00.000Z",
                yAxisValue: "216"
            ),
            ChartDataPoint(
                xAxisValue: "2021-07-05T00:00:00.000Z",
                yAxisValue: "190"
            ),
            ChartDataPoint(
                xAxisValue: "2021-07-06T00:00:00.000Z",
                yAxisValue: "140"
            ),
            ChartDataPoint(
                xAxisValue: "2021-07-07T00:00:00.000Z",
                yAxisValue: "106"
            ),
            ChartDataPoint(
                xAxisValue: "2021-07-08T00:00:00.000Z",
                yAxisValue: "135"
            ),
            ChartDataPoint(
                xAxisValue: "2021-07-09T00:00:00.000Z",
                yAxisValue: "138"
            ),
            ChartDataPoint(
                xAxisValue: "2021-07-10T00:00:00.000Z",
                yAxisValue: "131"
            )
        ]

        let chartDataSet = ChartDataSet(data: chartDataPoints, groupBy: .day)

        LineChart(chartDataSet: chartDataSet, isSelected: false)
            .padding()
            .previewLayout(.fixed(width: 400, height: 200))
    }
}
