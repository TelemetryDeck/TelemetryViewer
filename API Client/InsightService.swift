//
//  InsightService.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 19.05.21.
//

import Foundation
import SwiftUI

class InsightService: ObservableObject {
    let api: APIRepresentative

    @Published var insightGroupsByAppID: [UUID: [DTO.InsightGroup]] = [:]
    @Published var loadingAppIDs = Set<UUID>()
    @Published var selectedInsightGroupID: UUID?

    private var lastLoadTimeByAppID: [UUID: Date] = [:]

    init(api: APIRepresentative) {
        self.api = api
    }

    func isAppLoading(id appID: UUID) -> Bool {
        return loadingAppIDs.contains(appID)
    }

    /// Retrieve insight groups for the specified app. Will automatically load groups if none is present, or the data is outdated
    func insightGroups(for appID: UUID) -> [DTO.InsightGroup]? {
        let insightGroups = insightGroupsByAppID[appID]

        if insightGroups == nil {
            print("Insight Groups not found for appID \(appID), asking server...")
            getInsightGroups(for: appID)
        } else if let lastLoadTime = lastLoadTimeByAppID[appID], abs(lastLoadTime.timeIntervalSinceNow) > 60 * 5 { // data is over 5 minutes old
            print("Insight Groups too old for appID \(appID), asking server...")
            getInsightGroups(for: appID)
        }

        if (selectedInsightGroupID == nil || insightGroups?.filter { $0.id == selectedInsightGroupID }.isEmpty == true), let firstInsightGroupID = insightGroups?.first?.id {
            selectedInsightGroupID = firstInsightGroupID
        }

        return insightGroups
    }

    func insightGroup(id insightGroupID: UUID, in appID: UUID) -> DTO.InsightGroup? {
        guard let insightGroups = insightGroups(for: appID) else { return nil }

        guard let insightGroup = insightGroups.first(where: { $0.id == insightGroupID }) else {
            print("Insight Groups not found for id \(insightGroupID), asking server...")
            getInsightGroups(for: appID)

            return nil
        }

        return insightGroup
    }

    func insight(id insightID: UUID, in insightGroupID: UUID, in appID: UUID) -> DTO.InsightDTO? {
        guard let insightGroup = insightGroup(id: insightGroupID, in: appID) else { return nil }

        return insightGroup.insights.first { $0.id == insightID }
    }

    private func getInsightGroups(for appID: UUID, callback: ((Result<[DTO.InsightGroup], TransferError>) -> Void)? = nil) {
        guard !loadingAppIDs.contains(appID) else { return }

        loadingAppIDs.insert(appID)
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups")

        api.get(url) { [unowned self] (result: Result<[DTO.InsightGroup], TransferError>) in
            switch result {
            case let .success(foundInsightGroups):
                DispatchQueue.main.async {
                    self.insightGroupsByAppID[appID] = foundInsightGroups.sorted(by: { $0.order ?? 0 < $1.order ?? 0 })
                }

            case let .failure(error):
                api.handleError(error)
            }

            self.loadingAppIDs.remove(appID)
            self.lastLoadTimeByAppID[appID] = Date()
            callback?(result)
        }
    }

    func create(insightGroupNamed: String, for appID: UUID, callback: ((Result<DTO.InsightGroup, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups")

        api.post(["title": insightGroupNamed], to: url) { [unowned self] (result: Result<DTO.InsightGroup, TransferError>) in
            self.getInsightGroups(for: appID) { _ in
                callback?(result)
            }
        }
    }

    func update(insightGroup: DTO.InsightGroup, in appID: UUID, callback: ((Result<DTO.InsightGroup, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups", insightGroup.id.uuidString)

        api.patch(insightGroup, to: url) { [unowned self] (result: Result<DTO.InsightGroup, TransferError>) in
            self.getInsightGroups(for: appID)
            callback?(result)
        }
    }

    func delete(insightGroupID: UUID, in appID: UUID, callback: ((Result<DTO.InsightGroup, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups", insightGroupID.uuidString)

        api.delete(url) { [unowned self] (result: Result<DTO.InsightGroup, TransferError>) in
            self.getInsightGroups(for: appID)
            callback?(result)
        }
    }

    func create(insightWith requestBody: InsightDefinitionRequestBody, in insightGroupID: UUID, for appID: UUID, callback: ((Result<DTO.InsightCalculationResult, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups", insightGroupID.uuidString, "insights")

        api.post(requestBody, to: url) { [unowned self] (result: Result<DTO.InsightCalculationResult, TransferError>) in
            self.getInsightGroups(for: appID)
            callback?(result)
        }
    }

    func update(insightID: UUID, in insightGroupID: UUID, in appID: UUID, with insightUpdateRequestBody: InsightDefinitionRequestBody, callback: ((Result<DTO.InsightCalculationResult, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups", insightGroupID.uuidString, "insights", insightID.uuidString)

        api.patch(insightUpdateRequestBody, to: url) { [unowned self] (result: Result<DTO.InsightCalculationResult, TransferError>) in
            self.getInsightGroups(for: appID)
            callback?(result)
        }
    }

    func delete(insightID: UUID, in insightGroupID: UUID, in appID: UUID, callback: ((Result<String, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups", insightGroupID.uuidString, "insights", insightID.uuidString)

        api.delete(url) { [unowned self] (result: Result<String, TransferError>) in
            self.getInsightGroups(for: appID)
            callback?(result)
        }
    }
}
