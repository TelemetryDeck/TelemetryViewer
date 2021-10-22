//
//  AppService.swift
//  AppService
//
//  Created by Daniel Jilg on 17.08.21.
//

import Combine
import Foundation
import DataTransferObjects

class AppService: ObservableObject {
    private let api: APIClient
    private let cache: CacheLayer
    private let errorService: ErrorService
    
    private let loadingState = Cache<DTOv2.App.ID, LoadingState>()
        
    var loadingCancellable: AnyCancellable?
    var cacheCancellable: AnyCancellable?
    
    init(api: APIClient, cache: CacheLayer, errors: ErrorService) {
        self.api = api
        self.cache = cache
        errorService = errors
        
        loadingCancellable = loadingState.objectWillChange.receive(on: DispatchQueue.main).sink { [weak self] in self?.objectWillChange.send() }
        cacheCancellable = cache.appCache.objectWillChange.receive(on: DispatchQueue.main).sink { [weak self] in self?.objectWillChange.send() }
    }
    
    func loadingState(for appID: DTOv2.App.ID) -> LoadingState {
        let loadingState = loadingState[appID] ?? .idle
        
        // after 60 seconds, clear the error, allowing another load
        switch loadingState {
        case let .error(_, date):
            if date < Date() - 60 {
                self.loadingState[appID] = .idle
                return .idle
            }
        default:
            break
        }
        
        return loadingState
    }
    
    func app(withID appID: DTOv2.App.ID) -> DTOv2.App? {
        guard let app = cache.appCache[appID] else {
            retrieveApp(with: appID)
            return nil
        }
        
        if cache.appCache.needsUpdate(forKey: appID) {
            retrieveApp(with: appID)
        }
        
        return app
    }
    
    func retrieveApp(with appID: DTOv2.App.ID) {
        cache.queue.async { [weak self] in
            self?.performRetrieval(ofAppWithID: appID)
        }
    }
    
    func create(appNamed name: String, callback: ((Result<TelemetryApp, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps")

        api.post(["name": name], to: url) { [unowned self] (result: Result<TelemetryApp, TransferError>) in
            callback?(result)
            
            if let userToken = api.userToken?.bearerTokenAuthString {
                cache.organizationCache.removeValue(forKey: userToken)
            }
        }
    }

    func update(appID: UUID, newName: String, callback: ((Result<TelemetryApp, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString)

        api.patch(["name": newName], to: url) { [unowned self] (result: Result<TelemetryApp, TransferError>) in
//            if let userToken = api.userToken?.bearerTokenAuthString {
//                cache.organizationCache.removeValue(forKey: userToken)
//            }
            cache.appCache.removeValue(forKey: appID)
            callback?(result)
        }
    }

    func delete(appID: UUID, callback: ((Result<String, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString)

        api.delete(url) { [unowned self] (result: Result<String, TransferError>) in
            if let userToken = api.userToken?.bearerTokenAuthString {
                cache.organizationCache.removeValue(forKey: userToken)
            }
            cache.appCache.removeValue(forKey: appID)
            callback?(result)
        }
    }
}

private extension AppService {
    func performRetrieval(ofAppWithID appID: DTOv2.App.ID) {
        switch loadingState(for: appID) {
        case .loading, .error:
            return
        default:
            break
        }

        loadingState[appID] = .loading
        
        let url = api.urlForPath(apiVersion: .v2, "apps", appID.uuidString)
        
        api.get(url) { [weak self] (result: Result<DTOv2.App, TransferError>) in
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
