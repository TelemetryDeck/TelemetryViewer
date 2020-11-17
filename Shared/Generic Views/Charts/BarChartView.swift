//
//  LineChartView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 29.09.20.
//

import SwiftUI

struct BarChartView: View {
    var data: ChartData
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom) {
                ForEach(data.data, id: \.self) { dataEntry in
                    BarView(data: data, dataEntry: dataEntry, geometry: geometry)
                }
            }
        }
        .padding(.bottom)
        
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

struct BarChartView_Previews: PreviewProvider {
    static var previews: some View {
        let chartData = try! ChartData(data: [
            .init(date: Date(timeIntervalSinceNow: -3600*24*9), value: 1),
            .init(date: Date(timeIntervalSinceNow: -3600*24*8), value: 20),
            .init(date: Date(timeIntervalSinceNow: -3600*24*7), value: 30),
            .init(date: Date(timeIntervalSinceNow: -3600*24*6), value: 0),
            .init(date: Date(timeIntervalSinceNow: -3600*24*4), value: 30),
            .init(date: Date(timeIntervalSinceNow: -3600*24*3), value: 80),
            .init(date: Date(timeIntervalSinceNow: -3600*24*2), value: 24),
            .init(date: Date(timeIntervalSinceNow: -3600*24*1), value: 60),
        ])
        
        BarChartView(data: chartData)
            .padding()
            .previewLayout(.fixed(width: 400, height: 200))
    }
}


struct BarView: View {
    let data: ChartData
    let dataEntry: ChartDataPoint
    let geometry: GeometryProxy
    
    @State private var isHovering = false
    
    var body: some View {
        let percentage = CGFloat(dataEntry.value / data.highestValue)
        
        VStack {
            Text(dataEntry.value.stringValue)
                .font(.footnote)
                .foregroundColor(isHovering ? .grayColor : .clear)
                .offset(x: 0, y: isHovering ? 0 : 20)
            RoundedCorners(tl: 5, tr: 5, bl: 0, br: 0)
                .fill(isHovering ? Color.accentColor : Color.accentColor.opacity(0.7))
                .frame(height: percentage * geometry.size.height)
                .overlay(Rectangle()
                            .foregroundColor(Color.grayColor.opacity(0.5))
                            .cornerRadius(3.0)
                            .offset(x: 0, y: 3)
                            .padding(.horizontal, -2)
                            .frame(height: 3),
                         alignment: .bottom)
            
        }
        .onHover { hover in
            isHovering = hover
        }
        .animation(.easeOut)
    }
}
