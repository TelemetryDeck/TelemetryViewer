//
//  AppService.swift
//  AppService
//
//  Created by Daniel Jilg on 17.08.21.
//

import Combine
import DataTransferObjects
import Foundation

class AppService: ObservableObject {
    private let api: APIClient
    private let errorService: ErrorService
    private let orgService: OrgService
    
    private let loadingState = Cache<DTOv2.App.ID, LoadingState>()
        
    var loadingCancellable: AnyCancellable?
    
    @Published var appDictionary: [DTOv2.App.ID: DTOv2.App] = [:]
    @Published var loadingStateDictionary: [DTOv2.App.ID: LoadingState] = [:]
    
    init(api: APIClient, errors: ErrorService, orgService: OrgService) {
        self.api = api
        errorService = errors
        self.orgService = orgService
        
        loadingCancellable = loadingState.objectWillChange.receive(on: DispatchQueue.main).sink { [weak self] in self?.objectWillChange.send() }
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
        return appDictionary[appID]
    }
    
    func retrieveApp(with appID: DTOv2.App.ID, callback: ((Result<DTOv2.App, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath(apiVersion: .v2, "apps", appID.uuidString)
        api.get(url) { (result: Result<DTOv2.App, TransferError>) in
            callback?(result)
        }
    }
    
    func retrieveApp(withID appID: DTOv2.App.ID) async throws -> DTOv2.App {
//        guard loadingStateDictionary[appID] != .loading else { let error: TransferError = .transferFailed; throw error }
//        loadingStateDictionary[appID] = .loading
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<DTOv2.App, Error>) in
            let url = api.urlForPath(apiVersion: .v2, "apps", appID.uuidString)
            api.get(url) { (result: Result<DTOv2.App, TransferError>) in
                switch result {
                case let .success(app):

                    continuation.resume(returning: app)

                case let .failure(error):
                    self.errorService.handle(transferError: error)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func create(appNamed name: String, callback: ((Result<DTOv2.App, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath(apiVersion: .v2, "apps")

        api.post(["name": name], to: url) { [unowned self] (result: Result<DTOv2.App, TransferError>) in
            
            if let app = try? result.get() {
                appDictionary[app.id] = app
                orgService.organization?.appIDs.append(app.id)
            }
            
            callback?(result)
        }
    }

    func update(appID: UUID, newName: String, callback: ((Result<DTOv2.App, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath(apiVersion: .v2, "apps", appID.uuidString)

        api.patch(["name": newName], to: url) { [unowned self] (result: Result<DTOv2.App, TransferError>) in
            
            if let app = try? result.get() {
                appDictionary[app.id] = app
            }
            
            callback?(result)
        }
    }

    func delete(appID: UUID, callback: ((Result<[String: String], TransferError>) -> Void)? = nil) {
        let url = api.urlForPath(apiVersion: .v2, "apps", appID.uuidString)

        api.delete(url) { [unowned self] (result: Result<[String: String], TransferError>) in

            appDictionary[appID] = nil
            orgService.organization?.appIDs = (orgService.organization?.appIDs.filter { $0 != appID })!
            callback?(result)
        }
    }
}
