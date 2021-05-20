//
//  InsightCalculationService.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 18.05.21.
//

import Foundation
import SwiftUI

class InsightCalculationService: ObservableObject {
    let api: APIRepresentative

    @Published var calculationResultsByInsightID: [UUID: DTO.InsightCalculationResult] = [:]
    @Published var loadingInsightIDs = Set<UUID>()
    @Published var errorInsightIDs = Set<UUID>()

    /// The beginning of the time window. If nil, defaults to current Date minus 30 days
    @Published var timeWindowBeginning = Date() - 30 * 24 * 3600 {
        didSet {
            print("new beginning: \(timeWindowBeginning)")
            invalidateAllCalculationResults()
        }
    }

    /// The end of the currently displayed time window. If nil, defaults to date()
    @Published var timeWindowEnd = Date() {
        didSet {
            print("new end: \(timeWindowEnd)")
            invalidateAllCalculationResults()
        }
    }

    init(api: APIRepresentative) {
        self.api = api
    }

    enum CurrentOrPrevious {
        case current
        case previous
    }
    
    func setTimeIntervalTo(days: Int) {
        timeWindowEnd = Date()
        timeWindowBeginning = Date() - TimeInterval(days) * 24 * 3600
    }

    func setTimeIntervalTo(month currentOrPrevious: CurrentOrPrevious) {
        let calendar = Calendar.current
        
        let calendarComponents: Set<Calendar.Component> = [.year, .month]

        switch currentOrPrevious {
        case .current:
            // current month
            timeWindowEnd = Date()
            let components = calendar.dateComponents(calendarComponents, from: timeWindowEnd)
            timeWindowBeginning = calendar.date(from: components)!
        case .previous:
            // previous month
            let beginningOfThisMonth = calendar.date(from: calendar.dateComponents(calendarComponents, from: Date()))!
            let endOfPreviousMonth = calendar.date(byAdding: (DateComponents(minute: -1)), to: beginningOfThisMonth)!
            let beginningOfPreviousMonth = calendar.date(from: calendar.dateComponents(calendarComponents, from: endOfPreviousMonth))!
            
            timeWindowBeginning = beginningOfPreviousMonth
            timeWindowEnd = endOfPreviousMonth
        }
    }
    
    func setTimeIntervalTo(week currentOrPrevious: CurrentOrPrevious) {
        let calendar = Calendar.current
        let beginningOfCurrentWeek = calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: Date()).date!

        switch currentOrPrevious {
        case .current:
            // current week
            timeWindowEnd = Date()
            timeWindowBeginning = beginningOfCurrentWeek
        case .previous:
            // previous week
            let endOfPreviousWeek = calendar.date(byAdding: (DateComponents(minute: -1)), to: beginningOfCurrentWeek)!
            let beginningOfPreviousWeek = calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: endOfPreviousWeek).date!
            timeWindowBeginning = beginningOfPreviousWeek
            timeWindowEnd = endOfPreviousWeek
        }
    }
    
    func setTimeIntervalTo(quarter currentOrPrevious: CurrentOrPrevious) {
        let calendar = Calendar.current

        let month = Double(calendar.component(.month, from: Date()))
        let numberOfMonths = Double(calendar.monthSymbols.count)
        let numberOfMonthsInQuarter = numberOfMonths / 4
        let currentQuarterNumber = Int(ceil(month / numberOfMonthsInQuarter))
        let firstMonthInQuarterNumber = ((currentQuarterNumber - 1) * Int(numberOfMonthsInQuarter)) + 1
        
        var components = DateComponents()
        components.month = firstMonthInQuarterNumber
        components.year = calendar.component(.year, from: Date())
        let beginningOfCurrentQuarter = calendar.date(from: components)!
        
        switch currentOrPrevious {
        case .current:
            // current week
            timeWindowEnd = Date()
            timeWindowBeginning = beginningOfCurrentQuarter
        case .previous:
            // previous week
            let endOfPreviousQuarter = calendar.date(byAdding: DateComponents(minute: -1), to: beginningOfCurrentQuarter)!
            let beginningOfPreviousQuarter = calendar.date(byAdding: DateComponents(month: -3), to: beginningOfCurrentQuarter)!
            
            timeWindowBeginning = beginningOfPreviousQuarter
            timeWindowEnd = endOfPreviousQuarter
        }
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    var timeIntervalDescription: String {
        return "\(dateFormatter.string(from: timeWindowBeginning)) – \(dateFormatter.string(from: timeWindowEnd))"
    }

    func isInsightCalculating(id insightID: UUID) -> Bool {
        return loadingInsightIDs.contains(insightID)
    }

    func isInsightCalculationFailed(id insightID: UUID) -> Bool {
        return errorInsightIDs.contains(insightID)
    }

    /// Retrieve data for the specified insight. Will automatically load data if none is present, or the data is outdated
    func insightData(for insightID: UUID, in insightGroupID: UUID, in appID: UUID) -> DTO.InsightCalculationResult? {
        let insightData = calculationResultsByInsightID[insightID]

        if insightData == nil {
            getInsightData(for: insightID, in: insightGroupID, in: appID)
        } else if abs(insightData!.calculatedAt.timeIntervalSinceNow) > 60 * 5 { // data is over 5 minutes old
            getInsightData(for: insightID, in: insightGroupID, in: appID)
        }

        return insightData
    }

    private func invalidateAllCalculationResults() {
        calculationResultsByInsightID = [:]
    }

    func getInsightData(for insightID: UUID, in insightGroupID: UUID, in appID: UUID, callback: ((Result<DTO.InsightCalculationResult, TransferError>) -> Void)? = nil) {
        guard !loadingInsightIDs.contains(insightID) else { return }
        errorInsightIDs.remove(insightID)
        loadingInsightIDs.insert(insightID)

        let timeWindowEndIsToday = Calendar.current.isDateInToday(timeWindowEnd)

        let url = api.urlForPath("apps", appID.uuidString, "insightgroups", insightGroupID.uuidString, "insights",
                                 insightID.uuidString,
                                 Formatter.iso8601noFS.string(from: timeWindowBeginning),
                                 Formatter.iso8601noFS.string(from: timeWindowEndIsToday ? Date() : timeWindowEnd))

        api.get(url) { [unowned self] (result: Result<DTO.InsightCalculationResult, TransferError>) in
            if let insightDTO = try? result.get() {
                withAnimation {
                    self.calculationResultsByInsightID[insightID] = insightDTO
                }
            } else {
                errorInsightIDs.insert(insightID)
            }

            loadingInsightIDs.remove(insightID)

            callback?(result)
        }
    }
}
