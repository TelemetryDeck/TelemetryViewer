//
//  LexiconService.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 12.05.21.
//

import Foundation
import SwiftUI

class LexiconService: ObservableObject {
    @Published var lexiconSignals: [UUID: [DTO.LexiconSignalDTO]] = [:]
    @Published var lexiconPayloadKeys: [UUID: [DTO.LexiconPayloadKey]] = [:]
    @Published var loadingAppIDs: Set<UUID> = Set<UUID>()
    
    let api: APIRepresentative
    
    init(api: APIRepresentative) {
        self.api = api
    }
    
    func signalTypes(for appID: UUID) -> [DTO.LexiconSignalDTO] {
        lexiconSignals[appID] ?? []
    }
    
    func payloadKeys(for appID: UUID) -> [DTO.LexiconPayloadKey] {
        lexiconPayloadKeys[appID] ?? []
    }
    
    func isLoading(appID: UUID) -> Bool {
        loadingAppIDs.contains(appID)
    }
    
    func getSignalTypes(for appID: UUID, callback: ((Result<[DTO.LexiconSignalDTO], TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "lexicon", "signaltypes")
        
        loadingAppIDs.insert(appID)

        api.get(url) { [unowned self] (result: Result<[DTO.LexiconSignalDTO], TransferError>) in
            switch result {
            case let .success(lexiconItems):
                self.lexiconSignals[appID] = lexiconItems
            case let .failure(error):
                api.handleError(error)
            }
            
            loadingAppIDs.insert(appID)
            callback?(result)
        }
    }
    
    func getPayloadKeys(for appID: UUID, callback: ((Result<[DTO.LexiconPayloadKey], TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "lexicon", "payloadkeys")
        
        loadingAppIDs.insert(appID)

        api.get(url) { [unowned self] (result: Result<[DTO.LexiconPayloadKey], TransferError>) in
            switch result {
            case let .success(lexiconItems):
                self.lexiconPayloadKeys[appID] = lexiconItems
            case let .failure(error):
                api.handleError(error)
            }

            loadingAppIDs.insert(appID)
            callback?(result)
        }
    }
}
