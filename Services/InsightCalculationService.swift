//
//  InsightCalculationService.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 18.05.21.
//

import Foundation
import SwiftUI
import DataTransferObjects

struct ExpandedInsightCalculationResult {
    let insightData: DTOv1.InsightCalculationResult
    let chartDataSet: ChartDataSet
}

class InsightCalculationService: ObservableObject {
    let api: APIClient

    @Published var calculationResultsByInsightID: [UUID: ExpandedInsightCalculationResult] = [:]
    @Published var loadingInsightIDs = Set<UUID>()
    @Published var errorInsightIDs = Set<UUID>()

    @Published var timeWindowBeginning: RelativeDateDescription = .beginning(of: .previous(.month)) { didSet { invalidateAllCalculationResults() }}
    @Published var timeWindowEnd: RelativeDateDescription = .end(of: .current(.month)) { didSet { invalidateAllCalculationResults() }}

    var timeWindowBeginningDate: Date { resolvedDate(from: timeWindowBeginning, defaultDate: Date() - 30 * 24 * 3600) }
    var timeWindowEndDate: Date { resolvedDate(from: timeWindowEnd, defaultDate: Date()) }

    func resolvedDate(from date: RelativeDateDescription, defaultDate: Date) -> Date {
        let currentDate = Date()

        switch date {
        case .end(of: let of):
            switch of {
            case .current(let calendarComponent):
                return currentDate.end(of: calendarComponent) ?? defaultDate
            case .previous(let calendarComponent):
                return currentDate.beginning(of: calendarComponent)?.adding(calendarComponent, value: -1).end(of: calendarComponent) ?? defaultDate
            }

        case .beginning(of: let of):
            switch of {
            case .current(let calendarComponent):
                return currentDate.beginning(of: calendarComponent) ?? defaultDate
            case .previous(let calendarComponent):
                return currentDate.beginning(of: calendarComponent)?.adding(calendarComponent, value: -1).beginning(of: calendarComponent) ?? defaultDate
            }

        case .goBack(days: let days):
            return currentDate.adding(.day, value: -days).beginning(of: .day) ?? defaultDate

        case .absolute(date: let date):
            return date
        }
    }

    init(api: APIClient) {
        self.api = api
    }

    func setTimeIntervalTo(days: Int) {
        timeWindowEnd = .end(of: .current(.day))
        timeWindowBeginning = .goBack(days: days)
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    var timeIntervalDescription: String {
        return "\(dateFormatter.string(from: timeWindowBeginningDate)) – \(dateFormatter.string(from: timeWindowEndDate))"
    }

    func isInsightCalculating(id insightID: UUID) -> Bool {
        return loadingInsightIDs.contains(insightID)
    }

    func isInsightCalculationFailed(id insightID: UUID) -> Bool {
        return errorInsightIDs.contains(insightID)
    }

    /// Retrieve data for the specified insight. Will automatically load data if none is present, or the data is outdated
    func calculationResult(for insightID: UUID, in insightGroupID: UUID, in appID: UUID) -> ExpandedInsightCalculationResult? {
        let chartDataSet = calculationResultsByInsightID[insightID]

        if chartDataSet == nil {
            getCalculationResult(for: insightID, in: insightGroupID, in: appID)
        } else if abs((chartDataSet?.insightData.calculatedAt ?? Date()).timeIntervalSinceNow) > 60 * 5 { // data is over 5 minutes old
            getCalculationResult(for: insightID, in: insightGroupID, in: appID)
        }

        return chartDataSet
    }

    private func invalidateAllCalculationResults() {
        calculationResultsByInsightID = [:]
    }

    func getCalculationResult(for insightID: UUID, in insightGroupID: UUID, in appID: UUID, callback: ((Result<DTOv1.InsightCalculationResult, TransferError>) -> Void)? = nil) {
        guard !loadingInsightIDs.contains(insightID) else { return }
        errorInsightIDs.remove(insightID)
        loadingInsightIDs.insert(insightID)

        let timeWindowEndIsToday = Calendar.current.isDateInToday(timeWindowEndDate)

        let url = api.urlForPath("apps", appID.uuidString, "insightgroups", insightGroupID.uuidString, "insights",
                                 insightID.uuidString,
                                 Formatter.iso8601noFS.string(from: timeWindowBeginningDate),
                                 Formatter.iso8601noFS.string(from: timeWindowEndIsToday ? Date() : timeWindowEndDate))

        api.get(url) { [unowned self] (result: Result<DTOv1.InsightCalculationResult, TransferError>) in
            if let insightDTO = try? result.get() {
                DispatchQueue.global(qos: .userInitiated).async {
                    let chartDataSet = ChartDataSet(
                        data: insightDTO.data,
                        groupBy: insightDTO.groupBy)
                    
                    let calculationResult = ExpandedInsightCalculationResult(insightData: insightDTO, chartDataSet: chartDataSet)
                    
                    DispatchQueue.main.async {
                        withAnimation {
                            self.calculationResultsByInsightID[insightID] = calculationResult
                        }
                    }
                }
            } else {
                errorInsightIDs.insert(insightID)
            }

            loadingInsightIDs.remove(insightID)

            callback?(result)
        }
    }
}
