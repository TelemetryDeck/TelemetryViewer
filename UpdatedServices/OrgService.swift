//
//  OrgService.swift
//  OrgService
//
//  Created by Daniel Jilg on 17.08.21.
//

import Foundation
import Combine
import DataTransferObjects
import TelemetryDeckClient

class OrgService: ObservableObject {
    private let api: APIClient
    private let cache: CacheLayer
    private let errorService: ErrorService
    
    @Published private(set) var loadingState: LoadingState = .idle
    
    var cacheCancellable: AnyCancellable?
    
    init(api: APIClient, cache: CacheLayer, errors: ErrorService) {
        self.api = api
        self.cache = cache
        self.errorService = errors
        
        cacheCancellable = cache.organizationCache.objectWillChange.receive(on: DispatchQueue.main).sink { _ in self.objectWillChange.send() }
    }
    
    var organization: DTOv2.Organization? {
        guard let userToken = api.userToken?.bearerTokenAuthString, let organization = cache.organizationCache[userToken] else {
            retrieveOrganization()
            return nil
        }
        
        if cache.organizationCache.needsUpdate(forKey: userToken) {
            retrieveOrganization()
        }
        
        return organization
    }
    
    func retrieveOrganization() {
        // after 60 seconds, clear the error, allowing another load
        switch loadingState {
        case .error(_, let date):
            if date < Date() - 60 {
                self.loadingState = .idle
            }
        default:
            break
        }
        
        cache.queue.async { [weak self] in
            self?.performRetrieval()
        }
    }
}

private extension OrgService {
    func performRetrieval() {
        switch loadingState {
        case .loading, .error(_, _):
            return
        default:
            break
        }
        
        guard let userToken = api.userToken?.bearerTokenAuthString else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.loadingState = .loading
        }
        
        let url = api.urlForPath(apiVersion: .v2, "organization")
        
        api.get(url) { [weak self] (result: Result<DTOv2.Organization, TransferError>) in
            switch result {
            case let .success(organization):
                self?.cache.queue.async {
                    self?.cache.organizationCache[userToken] = organization
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.loadingState = .finished(Date())
                    }
                }
            case let .failure(error):
                self?.errorService.handle(transferError: error)
                
                DispatchQueue.main.async { [weak self] in
                    self?.loadingState = .error(error.localizedDescription, Date())
                }
            }
        }
    }
}
