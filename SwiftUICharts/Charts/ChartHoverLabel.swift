//
//  ChartHoverLabel.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 06.07.21.
//

import DataTransferObjects
import SwiftUI

struct ChartHoverLabel: View {
    let dataEntry: ChartDataPoint
    let interval: InsightGroupByInterval

    var body: some View {
        VStack(alignment: .leading) {
            Text(dateString(from: dataEntry, groupedBy: interval))
                .font(.footnote)
                .bold()

            dataEntry.yAxisValue.map {
                Text("–")
                    .animatableNumber(value: $0, shouldFormatBigNumbers: true)
                    .smallValueStyle()
            }
        }
        .foregroundColor(.cardBackground)
        .padding(8)
        .background(Color.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 8)
    }
}

// struct ChartHoverLabel_Previews: PreviewProvider {
//    static var previews: some View {
//        ChartHoverLabel(dataEntry: .init(xAxisValue: "2021-06-28T00:00:00.000Z", yAxisValue: "15234"), interval: .hour)
//        ChartHoverLabel(dataEntry: .init(xAxisValue: "2021-06-28T00:00:00.000Z", yAxisValue: "15234"), interval: .day)
//        ChartHoverLabel(dataEntry: .init(xAxisValue: "2021-06-28T00:00:00.000Z", yAxisValue: "15234"), interval: .week)
//        ChartHoverLabel(dataEntry: .init(xAxisValue: "2021-06-28T00:00:00.000Z", yAxisValue: "15234"), interval: .month)
//    }
// }
