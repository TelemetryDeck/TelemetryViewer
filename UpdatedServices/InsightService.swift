//
//  InsightService.swift
//  InsightService
//
//  Created by Daniel Jilg on 17.08.21.
//

import Foundation
import Combine

class InsightService: ObservableObject {
    private let api: APIClient
    private let cache: CacheLayer
    private let errorService: ErrorService
    
    private let loadingState = Cache<DTOsWithIdentifiers.Insight.ID, LoadingState>()
    
    var loadingCancellable: AnyCancellable?
    var cacheCancellable: AnyCancellable?
    
    init(api: APIClient, cache: CacheLayer, errors: ErrorService) {
        self.api = api
        self.cache = cache
        self.errorService = errors
        
        loadingCancellable = loadingState.objectWillChange.receive(on: DispatchQueue.main).sink { [weak self] in self?.objectWillChange.send() }
        cacheCancellable = cache.insightCache.objectWillChange.receive(on: DispatchQueue.main).sink { [weak self] in self?.objectWillChange.send() }
    }
    
    func loadingState(for insightID: DTOsWithIdentifiers.Insight.ID) -> LoadingState {
        let loadingState = loadingState[insightID] ?? .idle
        
        // after 60 seconds, clear the error, allowing another load
        switch loadingState {
        case .error(_, let date):
            if date < Date() - 60 {
                self.loadingState[insightID] = .idle
                return .idle
            }
        default:
            break
        }
        
        return loadingState
    }
    
    func insight(withID insightID: DTOsWithIdentifiers.Insight.ID) -> DTOsWithIdentifiers.Insight? {
        guard let group = cache.insightCache[insightID] else {
            retrieveInsight(with: insightID)
            return nil
        }
        
        if cache.insightCache.needsUpdate(forKey: insightID) {
            retrieveInsight(with: insightID)
        }
        
        return group
    }
    
    func retrieveInsight(with insightID: DTOsWithIdentifiers.Insight.ID) {
        cache.queue.async { [weak self] in
            self?.performRetrieval(ofInsightWithID: insightID)
        }
    }
    
    func update(insightID: UUID, in insightGroupID: UUID, in appID: UUID, with insightDTO: DTOsWithIdentifiers.Insight, callback: ((Result<DTO.InsightCalculationResult, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups", insightGroupID.uuidString, "insights", insightID.uuidString)
        
        let insightUpdateRequestBody = InsightDefinitionRequestBody(
            order: insightDTO.order,
            title: insightDTO.title,
            subtitle: nil,
            signalType: insightDTO.signalType,
            uniqueUser: insightDTO.uniqueUser,
            filters: insightDTO.filters,
            rollingWindowSize: 0,
            breakdownKey: insightDTO.breakdownKey,
            groupBy: insightDTO.groupBy,
            displayMode: insightDTO.displayMode,
            groupID: insightDTO.groupID,
            id: insightDTO.id,
            isExpanded: insightDTO.isExpanded,
            shouldUseDruid: true
        )

        let oldGroupID = insight(withID: insightID)?.groupID
        let newGroupID = insightUpdateRequestBody.groupID
        let insightGroupHasChanged = oldGroupID != newGroupID

        api.patch(insightUpdateRequestBody, to: url) { [unowned self] (result: Result<DTO.InsightCalculationResult, TransferError>) in
//            if insightGroupHasChanged {
//                self.invalidateInsightGroups(forAppID: appID)
//                self.getInsightGroups(for: appID)
//            }
            
            retrieveInsight(with: insightID)
            
            callback?(result)
        }
    }

    func delete(insightID: UUID, in insightGroupID: UUID, in appID: UUID, callback: ((Result<String, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups", insightGroupID.uuidString, "insights", insightID.uuidString)

        api.delete(url) { [unowned self] (result: Result<String, TransferError>) in
            callback?(result)
        }
    }
}

private extension InsightService {
    func performRetrieval(ofInsightWithID insightID: DTOsWithIdentifiers.Insight.ID) {
        switch loadingState(for: insightID) {
        case .loading, .error(_, _):
            return
        default:
            break
        }

        loadingState[insightID] = .loading
        
        let url = api.urlForPath(apiVersion: .v2, "insights", insightID.uuidString)
        
        api.get(url) { [weak self] (result: Result<DTOsWithIdentifiers.Insight, TransferError>) in
            self?.cache.queue.async { [weak self] in
                switch result {
                case let .success(insight):
                    self?.cache.insightCache[insightID] = insight
                    self?.loadingState[insightID] = .finished(Date())
                case let .failure(error):
                    self?.errorService.handle(transferError: error)
                    self?.loadingState[insightID] = .error(error.localizedDescription, Date())
                }
            }
        }
    }
}
