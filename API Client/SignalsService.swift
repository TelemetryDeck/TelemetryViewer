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
    @Published var loadingAppIDs: [UUID] = []
    
    let api: APIRepresentative
    
    init(api: APIRepresentative) {
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

        api.get(url) { [unowned self] (result: Result<[DTO.Signal], TransferError>) in
            switch result {
            case let .success(signals):
                self.signalsForAppID[appID] = signals
            case let .failure(error):
                api.handleError(error)
            }

            callback?(result)
        }
    }
}
