//
//  OrgService.swift
//  OrgService
//
//  Created by Daniel Jilg on 17.08.21.
//

import Combine
import DataTransferObjects
import Foundation

class OrgService: ObservableObject {
    private let api: APIClient
    private let cache: CacheLayer
    private let errorService: ErrorService
    
    @Published private(set) var loadingState: LoadingState = .idle
    
    @Published var organization: DTOv2.Organization?

    var cacheCancellable: AnyCancellable?
    
    init(api: APIClient, cache: CacheLayer, errors: ErrorService) {
        self.api = api
        self.cache = cache
        errorService = errors
        
        cacheCancellable = cache.organizationCache.objectWillChange.receive(on: DispatchQueue.main).sink { _ in self.objectWillChange.send() }
    }
    
    func retrieveOrganization() {
        // after 60 seconds, clear the error, allowing another load
        switch loadingState {
        case let .error(_, date):
            if date < Date() - 60 {
                loadingState = .idle
            }
        default:
            break
        }
        
        cache.queue.async { [weak self] in
            self?.performRetrieval()
        }
    }
    
    func getOrganisation() {
        let locallyCachedOrganization = retrieveFromDisk()
        self.organization = locallyCachedOrganization
        
        self.loadingState = .loading
        
        Task {
            do {
                let org = try await self.retrieveOrganisation()
                DispatchQueue.main.async {
                    self.organization = org // this should be dispatchmain. or should it?
                        
                    self.loadingState = .finished(Date())
                }
            } catch {
                print(error.localizedDescription)
                        
                if let transferError = error as? TransferError {
                    self.loadingState = .error(transferError.localizedDescription, Date())
                } else {
                    self.loadingState = .error(error.localizedDescription, Date())
                }
            }
        }

    }
    
    func retrieveOrganisation() async throws -> DTOv2.Organization {
//        guard (api.userToken?.bearerTokenAuthString) != nil else { let error: Error = ; throw error } // make this an error type? also, is this guard needed? why? did daniel use this just due to caching stuff?
        
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<DTOv2.Organization, Error>) in
            let url = api.urlForPath(apiVersion: .v2, "organization")
            api.get(url) { (result: Result<DTOv2.Organization, TransferError>) in
                switch result {
                case let .success(org):
                    
                    self.saveToDisk(org: org)

                    continuation.resume(returning: org)

                case let .failure(error):
                    self.errorService.handle(transferError: error)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

private extension OrgService {
    func performRetrieval() {
        switch loadingState {
        case .loading, .error:
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
                    self?.saveToDisk(org: organization)
                    
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

/// this is interesting, do we want this for more than the org?
private extension OrgService {
    var organizationCacheFilePath: URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let cachesDirectoryUrl = urls[0]
        let fileUrl = cachesDirectoryUrl.appendingPathComponent("telemetrydeck.organization.json")
        let filePath = fileUrl.path
        
        if !fileManager.fileExists(atPath: filePath) {
            let contents = Data()
            fileManager.createFile(atPath: filePath, contents: contents)
        }
        
        return fileUrl
    }
    
    func saveToDisk(org: DTOv2.Organization) {
        guard let data = try? JSONEncoder.telemetryEncoder.encode(org) else { return }
        try? data.write(to: organizationCacheFilePath, options: .atomic)
    }
    
    func retrieveFromDisk() -> DTOv2.Organization? {
        guard let data = try? Data(contentsOf: organizationCacheFilePath) else { return nil }
        return try? JSONDecoder.telemetryDecoder.decode(DTOv2.Organization.self, from: data)
    }
}
