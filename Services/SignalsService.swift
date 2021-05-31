//
//  SignalsService.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 12.05.21.
//

import Foundation
import SwiftUI

class SignalsService: ObservableObject {
    @Published var signalsForAppID: [UUID: [DTO.Signal]] = [:]
    @Published var loadingAppIDs: Set<UUID> = Set<UUID>()
    
    let api: APIClient
    
    init(api: APIClient) {
        self.api = api
    }
    
    func signals(for appID: UUID) -> [DTO.Signal] {
        signalsForAppID[appID] ?? []
    }
    
    func isLoading(appID: UUID) -> Bool {
        loadingAppIDs.contains(appID)
    }
    
    func getSignals(for appID: UUID, callback: ((Result<[DTO.Signal], TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "signals")
        
        loadingAppIDs.insert(appID)

        api.get(url) { [unowned self] (result: Result<[DTO.Signal], TransferError>) in
            switch result {
            case let .success(signals):
                self.signalsForAppID[appID] = signals
            case let .failure(error):
                api.handleError(error)
            }

            loadingAppIDs.remove(appID)
            callback?(result)
        }
    }
}
