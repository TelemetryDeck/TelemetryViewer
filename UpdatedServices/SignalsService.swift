//
//  SignalsService.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 12.05.21.
//

import Foundation
import SwiftUI
import DataTransferObjects

class SignalsService: ObservableObject {
    @Published var signalsForAppID: [UUID: [DTOv1.IdentifiableSignal]] = [:]
    @Published var loadingAppIDs = Set<UUID>()
    
    let api: APIClient
    
    init(api: APIClient) {
        self.api = api
    }
    
    func signals(for appID: UUID) -> [DTOv1.IdentifiableSignal] {
        signalsForAppID[appID] ?? []
    }
    
    func isLoading(appID: UUID) -> Bool {
        loadingAppIDs.contains(appID)
    }
    
    func getSignals(for appID: UUID) {
        let url = api.urlForPath("apps", appID.uuidString, "signals")
        
        loadingAppIDs.insert(appID)

        api.get(url) { [unowned self] (result: Result<[DTOv1.Signal], TransferError>) in
            DispatchQueue.global(qos: .userInitiated).async {
                switch result {
                case let .success(signals):
                    let identifiableSignals = signals.map { $0.toIdentifiableSignal() }
                    DispatchQueue.main.async {
                        self.signalsForAppID[appID] = identifiableSignals
                    }
                case let .failure(error):
                    api.handleError(error)
                }

                DispatchQueue.main.async {
                    loadingAppIDs.remove(appID)
                }
            }
        }
    }
    
    @available(macOS 12.0, *)
    @MainActor
    func getSignalsAsync(for appID: UUID) async {
        let url = api.urlForPath("apps", appID.uuidString, "signals")
        do {
            let signals: [DTOv1.Signal] = try await api.get(url: url)
            signalsForAppID[appID] = signals.map{ $0.toIdentifiableSignal() }
        } catch {
            print(error)
        }
    }
}
