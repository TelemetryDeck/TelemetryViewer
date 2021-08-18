//
//  InsightGroupService.swift
//  InsightGroupService
//
//  Created by Daniel Jilg on 17.08.21.
//

import Foundation
import Combine

class GroupService: ObservableObject {
    private let api: APIClient
    private let cache: CacheLayer
    private let errorService: ErrorService
    
    private let loadingState = Cache<DTOsWithIdentifiers.Group.ID, LoadingState>()
    
    var loadingCancellable: AnyCancellable?
    var cacheCancellable: AnyCancellable?
    
    init(api: APIClient, cache: CacheLayer, errors: ErrorService) {
        self.api = api
        self.cache = cache
        self.errorService = errors
        
        loadingCancellable = loadingState.objectWillChange.receive(on: DispatchQueue.main).sink { [weak self] in self?.objectWillChange.send() }
        cacheCancellable = cache.groupCache.objectWillChange.receive(on: DispatchQueue.main).sink { [weak self] in self?.objectWillChange.send() }
    }
    
    func loadingState(for groupID: DTOsWithIdentifiers.Group.ID) -> LoadingState {
        let loadingState = loadingState[groupID] ?? .idle
        
        // after 60 seconds, clear the error, allowing another load
        switch loadingState {
        case .error(_, let date):
            if date < Date() - 60 {
                self.loadingState[groupID] = .idle
                return .idle
            }
        default:
            break
        }
        
        return loadingState
    }
    
    func group(withID groupID: DTOsWithIdentifiers.Group.ID) -> DTOsWithIdentifiers.Group? {
        guard let group = cache.groupCache[groupID] else {
            retrieveGroup(with: groupID)
            return nil
        }
        
        if cache.groupCache.needsUpdate(forKey: groupID) {
            retrieveGroup(with: groupID)
        }
        
        return group
    }
    
    func retrieveGroup(with groupID: DTOsWithIdentifiers.Group.ID) {
        cache.queue.async { [weak self] in
            self?.performRetrieval(ofGroupWithID: groupID)
        }
    }
}

private extension GroupService {
    func performRetrieval(ofGroupWithID groupID: DTOsWithIdentifiers.Group.ID) {
        switch loadingState(for: groupID) {
        case .loading, .error(_, _):
            return
        default:
            break
        }

        loadingState[groupID] = .loading
        
        let url = api.urlForPath(apiVersion: .v2, "groups", groupID.uuidString)
        
        api.get(url) { [weak self] (result: Result<DTOsWithIdentifiers.Group, TransferError>) in
            self?.cache.queue.async { [weak self] in
                switch result {
                case let .success(group):
                    self?.cache.groupCache[groupID] = group
                    self?.loadingState[groupID] = .finished(Date())
                case let .failure(error):
                    self?.errorService.handle(transferError: error)
                    self?.loadingState[groupID] = .error(error.localizedDescription, Date())
                }
            }
        }
    }
}
