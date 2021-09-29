//
//  InsightService.swift
//  InsightService
//
//  Created by Daniel Jilg on 17.08.21.
//

import Combine
import Foundation

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
        errorService = errors
        
        loadingCancellable = loadingState.objectWillChange.receive(on: DispatchQueue.main).sink { [weak self] in self?.objectWillChange.send() }
        cacheCancellable = cache.insightCache.objectWillChange.receive(on: DispatchQueue.main).sink { [weak self] in self?.objectWillChange.send() }
    }
    
    func loadingState(for insightID: DTOsWithIdentifiers.Insight.ID) -> LoadingState {
        let loadingState = loadingState[insightID] ?? .idle
        
        // after 60 seconds, clear the error, allowing another load
        switch loadingState {
        case let .error(_, date):
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
        guard let object = cache.insightCache[insightID] else {
            retrieveInsight(with: insightID)
            return nil
        }
        
        if cache.insightCache.needsUpdate(forKey: insightID) {
            retrieveInsight(with: insightID)
        }
        
        return object
    }
    
    func retrieveInsight(with insightID: DTOsWithIdentifiers.Insight.ID) {
        cache.queue.async { [weak self] in
            self?.performRetrieval(ofInsightWithID: insightID)
        }
    }
    
    func create(insightWith: DTOsWithIdentifiers.Insight, callback: ((Result<String, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath(apiVersion: .v2, "insights")
        
        api.post(insightWith, to: url, defaultValue: nil) { (result: Result<String, TransferError>) in
            callback?(result)
        }
    }
    
    func update(insightID: UUID, in insightGroupID: UUID, in appID: UUID, with insightDTO: DTOsWithIdentifiers.Insight, callback: ((Result<DTO.InsightCalculationResult, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath(apiVersion: .v2, "insights", insightID.uuidString)

        api.patch(insightDTO, to: url) { [unowned self] (result: Result<DTO.InsightCalculationResult, TransferError>) in
            retrieveInsight(with: insightID)
            
            callback?(result)
        }
    }

    func delete(insightID: UUID, callback: ((Result<String, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath(apiVersion: .v2, "insights", insightID.uuidString)
        
        api.delete(url) { (result: Result<String, TransferError>) in
            callback?(result)
        }
    }
    
    func widgetableInsightIDs(callback: (([UUID]) -> Void)) {
        callback([
            UUID(uuidString: "0EFDB5F0-446D-4468-95CB-2D5CD75AF8C8")!,
            UUID(uuidString: "C8DB1A2A-40DE-40F8-A4DD-741F3D97F9F3")!,
            UUID(uuidString: "6106D79C-215C-4EF7-9F10-BF9DF6344C1C")!,
            UUID(uuidString: "36ECF853-7651-40C1-BABF-6ED06324C16A")!
        ])
    }
}

private extension InsightService {
    func performRetrieval(ofInsightWithID insightID: DTOsWithIdentifiers.Insight.ID) {
        switch loadingState(for: insightID) {
        case .loading, .error:
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
