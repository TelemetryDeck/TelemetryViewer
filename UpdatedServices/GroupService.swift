//
//  InsightGroupService.swift
//  InsightGroupService
//
//  Created by Daniel Jilg on 17.08.21.
//

import Combine
import Foundation

class GroupService: ObservableObject {
    private let api: APIClient
    private let cache: CacheLayer
    private let errorService: ErrorService
    
    private let loadingState = Cache<DTOv2.Group.ID, LoadingState>()
    
    var loadingCancellable: AnyCancellable?
    var cacheCancellable: AnyCancellable?
    
    init(api: APIClient, cache: CacheLayer, errors: ErrorService) {
        self.api = api
        self.cache = cache
        errorService = errors
        
        loadingCancellable = loadingState.objectWillChange.receive(on: DispatchQueue.main).sink { [weak self] in self?.objectWillChange.send() }
        cacheCancellable = cache.groupCache.objectWillChange.receive(on: DispatchQueue.main).sink { [weak self] in self?.objectWillChange.send() }
    }
    
    func loadingState(for groupID: DTOv2.Group.ID) -> LoadingState {
        let loadingState = loadingState[groupID] ?? .idle
        
        // after 60 seconds, clear the error, allowing another load
        switch loadingState {
        case let .error(_, date):
            if date < Date() - 60 {
                self.loadingState[groupID] = .idle
                return .idle
            }
        default:
            break
        }
        
        return loadingState
    }
    
    func group(withID groupID: DTOv2.Group.ID) -> DTOv2.Group? {
        guard let group = cache.groupCache[groupID] else {
            retrieveGroup(with: groupID)
            return nil
        }
        
        if cache.groupCache.needsUpdate(forKey: groupID) {
            retrieveGroup(with: groupID)
        }
        
        return group
    }
    
    func retrieveGroup(with groupID: DTOv2.Group.ID) {
        cache.queue.async { [weak self] in
            self?.performRetrieval(ofGroupWithID: groupID)
        }
    }
    
    func create(insightGroupNamed: String, for appID: UUID, callback: ((Result<DTOv1.InsightGroup, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups")

        api.post(["title": insightGroupNamed], to: url) { (result: Result<DTOv1.InsightGroup, TransferError>) in
            callback?(result)
        }
    }

    func update(insightGroup: DTOv1.InsightGroup, in appID: UUID, callback: ((Result<DTOv1.InsightGroup, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups", insightGroup.id.uuidString)

        api.patch(insightGroup, to: url) { (result: Result<DTOv1.InsightGroup, TransferError>) in
            callback?(result)
        }
    }

    func delete(insightGroupID: UUID, in appID: UUID, callback: ((Result<DTOv1.InsightGroup, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups", insightGroupID.uuidString)

        api.delete(url) { (result: Result<DTOv1.InsightGroup, TransferError>) in
            // TODO:
            callback?(result)
        }
    }

//    func create(insightWith requestBody: InsightDefinitionRequestBody, in insightGroupID: UUID, for appID: UUID, callback: ((Result<DTO.InsightCalculationResult, TransferError>) -> Void)? = nil) {
//        let url = api.urlForPath("apps", appID.uuidString, "insightgroups", insightGroupID.uuidString, "insights")
//
//        api.post(requestBody, to: url) { [unowned self] (result: Result<DTO.InsightCalculationResult, TransferError>) in
//            self.retrieveGroup(with: insightGroupID)
//            callback?(result)
//        }
//    }
}

private extension GroupService {
    func performRetrieval(ofGroupWithID groupID: DTOv2.Group.ID) {
        switch loadingState(for: groupID) {
        case .loading, .error:
            return
        default:
            break
        }

        loadingState[groupID] = .loading
        
        let url = api.urlForPath(apiVersion: .v2, "groups", groupID.uuidString)
        
        api.get(url) { [weak self] (result: Result<DTOv2.Group, TransferError>) in
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
