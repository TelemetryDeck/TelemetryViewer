//
//  InsightService.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 19.05.21.
//

import Foundation
import SwiftUI
import DataTransferObjects

class OldInsightService: ObservableObject {
    let api: APIClient
    
    @Published var selectedInsightGroupID: UUID?
    
    init(api: APIClient) {
        self.api = api
    }
    
    /// Retrieve insight groups for the specified app. Will automatically load groups if none is present, or the data is outdated
    func insightGroups(for appID: UUID) -> [DTOv1.InsightGroup]? {
        return []
    }
    
    func insightGroup(id insightGroupID: UUID, in appID: UUID) -> DTOv1.InsightGroup? {
        return nil
    }
    
    func insight(id insightID: UUID, in insightGroupID: UUID, in appID: UUID) -> DTOv1.InsightDTO? {
        return nil
    }
    
    /// Removes the insight group from the cache, causing it to be reloaded from the server
    func invalidateInsightGroups(forAppID appID: UUID) {
    }
    
    
    // MARK: - Refreshing
    

    private func getInsightGroups(for appID: UUID, callback: ((Result<[DTOv1.InsightGroup], TransferError>) -> Void)? = nil) {
//        guard !appIDsLoadingInsightGroups.contains(appID) else { return }
//
//        appIDsLoadingInsightGroups.insert(appID)
//        let url = api.urlForPath("apps", appID.uuidString, "insightgroups")
//
//        api.get(url) { [unowned self] (result: Result<[DTO.InsightGroup], TransferError>) in
//            switch result {
//            case let .success(foundInsightGroups):
//                self.insightGroupsByAppID[appID] = foundInsightGroups.sorted(by: { $0.order ?? 0 < $1.order ?? 0 })
//
//                // check if the currently selected insight group id is part of the loaded ones,
//                // and remove it if that is not the case.
//                // if we don't do this, navigating to a newly created app will hang
//                if foundInsightGroups.filter({ $0.id == selectedInsightGroupID }).isEmpty {
//                    selectedInsightGroupID = nil
//                }
//
//            case let .failure(error):
//                api.handleError(error)
//            }
//
//            self.appIDsLoadingInsightGroups.remove(appID)
//            self.lastLoadTimeByAppID[appID] = Date()
//
//            callback?(result)
//        }
    }
    
    
    // MARK: - CRUD
    func create(insightGroupNamed: String, for appID: UUID, callback: ((Result<DTOv1.InsightGroup, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups")

        api.post(["title": insightGroupNamed], to: url) { [unowned self] (result: Result<DTOv1.InsightGroup, TransferError>) in
            self.getInsightGroups(for: appID) { _ in
                callback?(result)
            }
        }
    }

    func update(insightGroup: DTOv1.InsightGroup, in appID: UUID, callback: ((Result<DTOv1.InsightGroup, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups", insightGroup.id.uuidString)

        api.patch(insightGroup, to: url) { [unowned self] (result: Result<DTOv1.InsightGroup, TransferError>) in
            self.invalidateInsightGroups(forAppID: appID)
            self.getInsightGroups(for: appID)
            callback?(result)
        }
    }

    func delete(insightGroupID: UUID, in appID: UUID, callback: ((Result<DTOv1.InsightGroup, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups", insightGroupID.uuidString)

        api.delete(url) { [unowned self] (result: Result<DTOv1.InsightGroup, TransferError>) in
            self.getInsightGroups(for: appID) { _ in
                self.selectedInsightGroupID = nil
            }
            callback?(result)
        }
    }

    func create(insightWith requestBody: InsightDefinitionRequestBody, in insightGroupID: UUID, for appID: UUID, callback: ((Result<DTOv1.InsightCalculationResult, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups", insightGroupID.uuidString, "insights")

        api.post(requestBody, to: url) { [unowned self] (result: Result<DTOv1.InsightCalculationResult, TransferError>) in
            self.getInsightGroups(for: appID) { _ in
                callback?(result)
            }
        }
    }

    func update(insightID: UUID, in insightGroupID: UUID, in appID: UUID, with insightUpdateRequestBody: InsightDefinitionRequestBody, callback: ((Result<DTOv1.InsightCalculationResult, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups", insightGroupID.uuidString, "insights", insightID.uuidString)

        let oldGroupID = insight(id: insightID, in: insightGroupID, in: appID)?.group["id"]
        let newGroupID = insightUpdateRequestBody.groupID
        let insightGroupHasChanged = oldGroupID != newGroupID

        api.patch(insightUpdateRequestBody, to: url) { [unowned self] (result: Result<DTOv1.InsightCalculationResult, TransferError>) in
            if insightGroupHasChanged {
                self.invalidateInsightGroups(forAppID: appID)
                self.getInsightGroups(for: appID)
            }
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

class OlderInsightService: ObservableObject {
    let api: APIClient

    @Published var insightGroupsByAppID: [UUID: [DTOv1.InsightGroup]] = [:]

    /// A set of App IDs that are currently loading for an insight group
    ///
    /// Do not manually change this set. If an app's ID is in there, it means the service is currently
    /// loading insight groups for this app.
    @Published private(set) var appIDsLoadingInsightGroups = Set<UUID>()
    @Published var selectedInsightGroupID: UUID?

    private var lastLoadTimeByAppID: [UUID: Date] = [:]

    init(api: APIClient) {
        self.api = api
    }

    func isAppLoadingInsightGroups(id appID: UUID) -> Bool {
        return appIDsLoadingInsightGroups.contains(appID)
    }

    /// Removes the insight group from the cache, causing it to be reloaded from the server
    func invalidateInsightGroups(forAppID appID: UUID) {
        insightGroupsByAppID.removeValue(forKey: appID)
        lastLoadTimeByAppID.removeValue(forKey: appID)
    }

    /// Retrieve insight groups for the specified app. Will automatically load groups if none is present, or the data is outdated
    func insightGroups(for appID: UUID) -> [DTOv1.InsightGroup]? {
        let insightGroups = insightGroupsByAppID[appID]

        if insightGroups == nil {
            print("Insight Groups not found for appID \(appID), asking server...")
            getInsightGroups(for: appID)
        } else if let lastLoadTime = lastLoadTimeByAppID[appID], lastLoadTime < (Date() - 60 * 5) { // data is over 5 minutes old
            print("Insight Groups too old for appID \(appID), asking server...")
            getInsightGroups(for: appID)
        }

        if (selectedInsightGroupID == nil || insightGroups?.filter { $0.id == selectedInsightGroupID }.isEmpty == true), let firstInsightGroupID = insightGroups?.first?.id {
            selectedInsightGroupID = firstInsightGroupID
        }

        return insightGroups
    }

    func insightGroup(id insightGroupID: UUID, in appID: UUID) -> DTOv1.InsightGroup? {
        guard let insightGroups = insightGroups(for: appID) else { return nil }

        guard let insightGroup = insightGroups.first(where: { $0.id == insightGroupID }) else {
            return nil
        }

        return insightGroup
    }

    func insight(id insightID: UUID, in insightGroupID: UUID, in appID: UUID) -> DTOv1.InsightDTO? {
        guard let insightGroup = insightGroup(id: insightGroupID, in: appID) else { return nil }

        return insightGroup.insights.first { $0.id == insightID }
    }

    func getInsightGroups(for appID: UUID, callback: ((Result<[DTOv1.InsightGroup], TransferError>) -> Void)? = nil) {
        guard !appIDsLoadingInsightGroups.contains(appID) else { return }

        appIDsLoadingInsightGroups.insert(appID)
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups")

        api.get(url) { [unowned self] (result: Result<[DTOv1.InsightGroup], TransferError>) in
            switch result {
            case let .success(foundInsightGroups):
                self.insightGroupsByAppID[appID] = foundInsightGroups.sorted(by: { $0.order ?? 0 < $1.order ?? 0 })
                
                // check if the currently selected insight group id is part of the loaded ones,
                // and remove it if that is not the case.
                // if we don't do this, navigating to a newly created app will hang
                if foundInsightGroups.filter({ $0.id == selectedInsightGroupID }).isEmpty {
                    selectedInsightGroupID = nil
                }

            case let .failure(error):
                api.handleError(error)
            }

            self.appIDsLoadingInsightGroups.remove(appID)
            self.lastLoadTimeByAppID[appID] = Date()
            
            callback?(result)
        }
    }

    func create(insightGroupNamed: String, for appID: UUID, callback: ((Result<DTOv1.InsightGroup, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups")

        api.post(["title": insightGroupNamed], to: url) { [unowned self] (result: Result<DTOv1.InsightGroup, TransferError>) in
            self.getInsightGroups(for: appID) { _ in
                callback?(result)
            }
        }
    }

    func update(insightGroup: DTOv1.InsightGroup, in appID: UUID, callback: ((Result<DTOv1.InsightGroup, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups", insightGroup.id.uuidString)

        api.patch(insightGroup, to: url) { [unowned self] (result: Result<DTOv1.InsightGroup, TransferError>) in
            self.invalidateInsightGroups(forAppID: appID)
            self.getInsightGroups(for: appID)
            callback?(result)
        }
    }

    func delete(insightGroupID: UUID, in appID: UUID, callback: ((Result<DTOv1.InsightGroup, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups", insightGroupID.uuidString)

        api.delete(url) { [unowned self] (result: Result<DTOv1.InsightGroup, TransferError>) in
            self.getInsightGroups(for: appID) { _ in
                self.selectedInsightGroupID = nil
            }
            callback?(result)
        }
    }

    func create(insightWith requestBody: InsightDefinitionRequestBody, in insightGroupID: UUID, for appID: UUID, callback: ((Result<DTOv1.InsightCalculationResult, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups", insightGroupID.uuidString, "insights")

        api.post(requestBody, to: url) { [unowned self] (result: Result<DTOv1.InsightCalculationResult, TransferError>) in
            self.getInsightGroups(for: appID) { _ in
                callback?(result)
            }
        }
    }

    func update(insightID: UUID, in insightGroupID: UUID, in appID: UUID, with insightUpdateRequestBody: InsightDefinitionRequestBody, callback: ((Result<DTOv1.InsightCalculationResult, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups", insightGroupID.uuidString, "insights", insightID.uuidString)

        let oldGroupID = insight(id: insightID, in: insightGroupID, in: appID)?.group["id"]
        let newGroupID = insightUpdateRequestBody.groupID
        let insightGroupHasChanged = oldGroupID != newGroupID

        api.patch(insightUpdateRequestBody, to: url) { [unowned self] (result: Result<DTOv1.InsightCalculationResult, TransferError>) in
            if insightGroupHasChanged {
                self.invalidateInsightGroups(forAppID: appID)
                self.getInsightGroups(for: appID)
            }
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
