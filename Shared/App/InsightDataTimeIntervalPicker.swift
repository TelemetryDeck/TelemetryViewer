//
//  SwiftUIView.swift
//  Telemetry Viewer (macOS)
//
//  Created by Daniel Jilg on 18.05.21.
//

import SwiftUI

struct InsightDataTimeIntervalPicker: View {
    @EnvironmentObject var queryService: QueryService

    var body: some View {
        VStack {
            HStack {
                Button("7 Days") {
                    queryService.timeWindowEnd = .end(of: .current(.day))
                    queryService.timeWindowBeginning = .goBack(days: 7)
                }
                Button("30 Days") {
                    queryService.timeWindowEnd = .end(of: .current(.day))
                    queryService.timeWindowBeginning = .goBack(days: 30)
                }
                Button("90 Days") {
                    queryService.timeWindowEnd = .end(of: .current(.day))
                    queryService.timeWindowBeginning = .goBack(days: 90)
                }
                Button("365 Days") {
                    queryService.timeWindowEnd = .end(of: .current(.day))
                    queryService.timeWindowBeginning = .goBack(days: 365)
                }
            }

            Divider()

            HStack {
                Button("Last Week") { queryService.timeWindowEnd = .end(of: .previous(.weekOfYear))
                    queryService.timeWindowBeginning = .beginning(of: .previous(.weekOfYear))
                }
                Button("This Week") { queryService.timeWindowEnd = .end(of: .current(.weekOfYear))
                    queryService.timeWindowBeginning = .beginning(of: .current(.weekOfYear))
                }
            }
            HStack {
                Button("Last Month") { queryService.timeWindowEnd = .end(of: .previous(.month))
                    queryService.timeWindowBeginning = .beginning(of: .previous(.month))
                }
                Button("This Month") { queryService.timeWindowEnd = .end(of: .current(.month))
                    queryService.timeWindowBeginning = .beginning(of: .current(.month))
                }
                Button("2 Months") {
                    queryService.timeWindowEnd = .end(of: .current(.month))
                    queryService.timeWindowBeginning = .beginning(of: .previous(.month))
                }
            }

            HStack {
                Button("Last Year") { queryService.timeWindowEnd = .end(of: .previous(.year))
                    queryService.timeWindowBeginning = .beginning(of: .previous(.year))
                }
                Button("This Year") { queryService.timeWindowEnd = .end(of: .current(.year))
                    queryService.timeWindowBeginning = .beginning(of: .current(.year))
                }
            }

            let pickerTimeWindowBeginningBinding = Binding(
                get: { self.queryService.timeWindowBeginningDate },
                set: { self.queryService.timeWindowBeginning = .absolute(date: $0) }
            )

            let pickerTimeWindowEndBinding = Binding(
                get: { self.queryService.timeWindowEndDate },
                set: { self.queryService.timeWindowEnd = .absolute(date: $0) }
            )

            Divider()
            HStack {
                DatePicker("From", selection: pickerTimeWindowBeginningBinding, in: ...queryService.timeWindowEndDate, displayedComponents: .date)
                Divider()
                DatePicker("Until", selection: pickerTimeWindowEndBinding, in: ...Date(), displayedComponents: .date)
            }
        }
        .buttonStyle(SmallSecondaryButtonStyle())
        
    }
}
