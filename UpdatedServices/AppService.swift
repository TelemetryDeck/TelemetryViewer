//
//  AppService.swift
//  AppService
//
//  Created by Daniel Jilg on 17.08.21.
//

import Foundation
import Combine

class AppService: ObservableObject {
    private let api: APIClient
    private let cache: CacheLayer
    private let errorService: ErrorService
    
    private let loadingState = Cache<DTOsWithIdentifiers.App.ID, LoadingState>()
        
    var loadingCancellable: AnyCancellable?
    var cacheCancellable: AnyCancellable?
    
    init(api: APIClient, cache: CacheLayer, errors: ErrorService) {
        self.api = api
        self.cache = cache
        self.errorService = errors
        
        loadingCancellable = loadingState.objectWillChange.receive(on: DispatchQueue.main).sink { [weak self] in self?.objectWillChange.send() }
        cacheCancellable = cache.appCache.objectWillChange.receive(on: DispatchQueue.main).sink { [weak self] in self?.objectWillChange.send() }
    }
    
    func loadingState(for appID: DTOsWithIdentifiers.App.ID) -> LoadingState {
        let loadingState = loadingState[appID] ?? .idle
        
        // after 60 seconds, clear the error, allowing another load
        switch loadingState {
        case .error(_, let date):
            if date < Date() - 60 {
                self.loadingState[appID] = .idle
                return .idle
            }
        default:
            break
        }
        
        return loadingState
    }
    
    func app(withID appID: DTOsWithIdentifiers.App.ID) -> DTOsWithIdentifiers.App? {
        guard let app = cache.appCache[appID] else {
            retrieveApp(with: appID)
            return nil
        }
        
        if cache.appCache.needsUpdate(forKey: appID) {
            retrieveApp(with: appID)
        }
        
        return app
    }
    
    func retrieveApp(with appID: DTOsWithIdentifiers.App.ID) {
        cache.queue.async { [weak self] in
            self?.performRetrieval(ofAppWithID: appID)
        }
    }
}

private extension AppService {
    func performRetrieval(ofAppWithID appID: DTOsWithIdentifiers.App.ID) {
        switch loadingState(for: appID) {
        case .loading, .error(_, _):
            return
        default:
            break
        }

        loadingState[appID] = .loading
        
        let url = api.urlForPath(apiVersion: .v2, "apps", appID.uuidString)
        
        api.get(url) { [weak self] (result: Result<DTOsWithIdentifiers.App, TransferError>) in
            self?.cache.queue.async { [weak self] in
                switch result {
                case let .success(app):
                    self?.cache.appCache[appID] = app
                    self?.loadingState[appID] = .finished(Date())
                case let .failure(error):
                    self?.errorService.handle(transferError: error)
                    self?.loadingState[appID] = .error(error.localizedDescription, Date())
                }
            }
        }
    }
}
