//
//  InsightService.swift
//  InsightService
//
//  Created by Daniel Jilg on 17.08.21.
//

import Foundation
import Combine

class InsightResultService: ObservableObject {
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
        cacheCancellable = cache.insightCalculationResultCache.objectWillChange.receive(on: DispatchQueue.main).sink { [weak self] in self?.objectWillChange.send() }
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
    
    func insightCalculationResult(withID insightID: DTOsWithIdentifiers.Insight.ID) -> DTOsWithIdentifiers.InsightCalculationResult? {
        guard let insight = cache.insightCalculationResultCache[insightID] else {
            retrieveInsightCalculationResult(with: insightID)
            return nil
        }
        
        if cache.insightCalculationResultCache.needsUpdate(forKey: insightID) {
            retrieveInsightCalculationResult(with: insightID)
        }
        
        return insight
    }
    
    func retrieveInsightCalculationResult(with insightID: DTOsWithIdentifiers.Insight.ID) {
        cache.queue.async { [weak self] in
            self?.performRetrieval(ofInsightWithID: insightID)
        }
    }
}

private extension InsightResultService {
    func performRetrieval(ofInsightWithID insightID: DTOsWithIdentifiers.Insight.ID) {
        switch loadingState(for: insightID) {
        case .loading, .error(_, _):
            return
        default:
            break
        }

        loadingState[insightID] = .loading
        
        let url = api.urlForPath(apiVersion: .v2, "insights", insightID.uuidString, "result")
        
        api.get(url) { [weak self] (result: Result<DTOsWithIdentifiers.InsightCalculationResult, TransferError>) in
            self?.cache.queue.async { [weak self] in
                switch result {
                case let .success(insight):
                    self?.cache.insightCalculationResultCache[insightID] = insight
                    self?.loadingState[insightID] = .finished(Date())
                case let .failure(error):
                    self?.errorService.handle(transferError: error)
                    self?.loadingState[insightID] = .error(error.localizedDescription, Date())
                }
            }
        }
    }
}
