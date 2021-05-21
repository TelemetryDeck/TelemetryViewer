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
                Button("7 Days") {
                    insightCalculationService.timeWindowEnd = .end(of: .current(.day))
                    insightCalculationService.timeWindowBeginning = .goBack(days: 7)
                }
                Button("30 Days") {
                    insightCalculationService.timeWindowEnd = .end(of: .current(.day))
                    insightCalculationService.timeWindowBeginning = .goBack(days: 30)
                }
                Button("90 Days") {
                    insightCalculationService.timeWindowEnd = .end(of: .current(.day))
                    insightCalculationService.timeWindowBeginning = .goBack(days: 90)
                }
                Button("365 Days") {
                    insightCalculationService.timeWindowEnd = .end(of: .current(.day))
                    insightCalculationService.timeWindowBeginning = .goBack(days: 365)
                }
            }

            Divider()

            HStack {
                Button("Previous Week") { insightCalculationService.timeWindowEnd = .end(of: .previous(.weekOfYear))
                    insightCalculationService.timeWindowBeginning = .beginning(of: .previous(.weekOfYear))
                }
                Button("Current Week") { insightCalculationService.timeWindowEnd = .end(of: .current(.weekOfYear))
                    insightCalculationService.timeWindowBeginning = .beginning(of: .current(.weekOfYear))
                }
            }
            HStack {
                Button("Previous Month") { insightCalculationService.timeWindowEnd = .end(of: .previous(.month))
                    insightCalculationService.timeWindowBeginning = .beginning(of: .previous(.month))
                }
                Button("Current Month") { insightCalculationService.timeWindowEnd = .end(of: .current(.month))
                    insightCalculationService.timeWindowBeginning = .beginning(of: .current(.month))
                }
            }

            HStack {
                Button("Previous Year") { insightCalculationService.timeWindowEnd = .end(of: .previous(.year))
                    insightCalculationService.timeWindowBeginning = .beginning(of: .previous(.year))
                }
                Button("Current Year") { insightCalculationService.timeWindowEnd = .end(of: .current(.year))
                    insightCalculationService.timeWindowBeginning = .beginning(of: .current(.year))
                }
            }

            let pickerTimeWindowBeginningBinding = Binding(
                get: { self.insightCalculationService.timeWindowBeginningDate },
                set: { self.insightCalculationService.timeWindowBeginning = .absolute(date: $0) }
            )

            let pickerTimeWindowEndBinding = Binding(
                get: { self.insightCalculationService.timeWindowEndDate },
                set: { self.insightCalculationService.timeWindowEnd = .absolute(date: $0) }
            )

            Divider()
            HStack {
                DatePicker("From", selection: pickerTimeWindowBeginningBinding, in: ...insightCalculationService.timeWindowEndDate, displayedComponents: .date)
                Divider()
                DatePicker("Until", selection: pickerTimeWindowEndBinding, in: ...Date(), displayedComponents: .date)
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
