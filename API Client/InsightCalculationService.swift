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

    /// Retrieve data for the specified insight. Will automatically load data if none is present, or the data is outdated
    func insightData(for insightID: UUID, in insightGroupID: UUID, in appID: UUID) -> DTO.InsightCalculationResult? {
        let insightData = calculationResultsByInsightID[insightID]
        
        if insightData == nil {
            getInsightData(for: insightID, in: insightGroupID, in: appID)
        }
        
        return insightData
    }
    
    private func invalidateAllCalculationResults() {
        calculationResultsByInsightID = [:]
    }

    private func getInsightData(for insightID: UUID, in insightGroupID: UUID, in appID: UUID, callback: ((Result<DTO.InsightCalculationResult, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups", insightGroupID.uuidString, "insights",
                                 insightID.uuidString,
                                 Formatter.iso8601noFS.string(from: timeWindowBeginning),
                                 Formatter.iso8601noFS.string(from: timeWindowEnd))

        guard !loadingInsightIDs.contains(insightID) else { return }
        loadingInsightIDs.insert(insightID)

        api.get(url) { [unowned self] (result: Result<DTO.InsightCalculationResult, TransferError>) in
            if let insightDTO = try? result.get() {
                withAnimation {
                    self.calculationResultsByInsightID[insightID] = insightDTO
                }
            }

            loadingInsightIDs.remove(insightID)

            callback?(result)
        }
    }
}
