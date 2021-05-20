//
//  SwiftUIView.swift
//  Telemetry Viewer (macOS)
//
//  Created by Daniel Jilg on 18.05.21.
//

import SwiftUI

struct InsightDataTimeIntervalPicker: View {
    @EnvironmentObject var insightCalculationService: InsightCalculationService

    var body: some View {
        VStack {
            HStack {
                Button("7 Days") { insightCalculationService.setTimeIntervalTo(days: 7) }
                Button("30 Days") { insightCalculationService.setTimeIntervalTo(days: 30) }
                Button("90 Days") { insightCalculationService.setTimeIntervalTo(days: 90) }
                Button("365 Days") { insightCalculationService.setTimeIntervalTo(days: 365) }
            }

            Divider()

            HStack {
                Button("Previous Week") { insightCalculationService.setTimeIntervalTo(week: .previous) }
                Button("Current Week") { insightCalculationService.setTimeIntervalTo(week: .current) }
            }

            HStack {
                Button("Previous Month") { insightCalculationService.setTimeIntervalTo(month: .previous) }
                Button("Current Month") { insightCalculationService.setTimeIntervalTo(month: .current) }
            }

            HStack {
                Button("Previous Quarter") { insightCalculationService.setTimeIntervalTo(quarter: .previous) }
                Button("Current Quarter") { insightCalculationService.setTimeIntervalTo(quarter: .current) }
            }

            Divider()
            HStack {
                DatePicker("From", selection: $insightCalculationService.timeWindowBeginning, in: ...insightCalculationService.timeWindowEnd, displayedComponents: .date)
                Divider()
                DatePicker("Until", selection: $insightCalculationService.timeWindowEnd, in: ...Date(), displayedComponents: .date)
            }
        }
    }
}

struct InsightDataTimeIntervalPicker_Previews: PreviewProvider {
    static var previews: some View {
        InsightDataTimeIntervalPicker()
            .environmentObject(InsightCalculationService(api: APIRepresentative()))
    }
}
