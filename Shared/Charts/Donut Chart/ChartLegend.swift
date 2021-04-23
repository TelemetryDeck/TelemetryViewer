//
//  ChartLegend.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 23.04.21.
//

import SwiftUI
import TelemetryModels


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
    let chartDataPoints: [ChartDataPoint]
    
    
    private var donutLegendEntryValues: [DonutLegendEntryValue] {
        var values: [DonutLegendEntryValue] = []
        
        for (index, data) in chartDataPoints.enumerated() {
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
        }
    }
}
