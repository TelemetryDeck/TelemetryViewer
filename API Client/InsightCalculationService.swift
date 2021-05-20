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
