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
        HStack {
            DatePicker("From", selection: $insightCalculationService.timeWindowBeginning, in: ...insightCalculationService.timeWindowEnd, displayedComponents: .date)
            Text("–")
            DatePicker("Until", selection: $insightCalculationService.timeWindowEnd, in: ...Date(), displayedComponents: .date)
        }
    }
}

struct InsightDataTimeIntervalPicker_Previews: PreviewProvider {
    static var previews: some View {
        InsightDataTimeIntervalPicker()
    }
}
