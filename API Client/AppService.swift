//
//  AppService.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 20.05.21.
//

import Foundation
import SwiftUI

class AppService: ObservableObject {
    let api: APIRepresentative

    @Published var apps: [TelemetryApp]?
    @Published var isLoading: Bool = false
    @Published var selectedAppID: UUID?
    
    private var lastLoadTime: Date? = nil

    init(api: APIRepresentative) {
        self.api = api
    }
    
    func getTelemetryApps() -> [TelemetryApp] {
        if apps == nil && api.userNotLoggedIn == false {
            getApps()
        }
        
        return (apps ?? []).sorted { $0.name < $1.name }
    }
    
    func getSelectedApp() -> TelemetryApp? {
        if apps == nil && api.userNotLoggedIn == false {
            getApps()
        }
        
        return apps?.first { $0.id == selectedAppID }
    }
    
    private func getApps(callback: ((Result<[TelemetryApp], TransferError>) -> Void)? = nil) {
        guard !isLoading else { return }
        
        isLoading = true
        let url = api.urlForPath("apps")

        api.get(url) { [unowned self] (result: Result<[TelemetryApp], TransferError>) in
            switch result {
            case let .success(apps):
                DispatchQueue.main.async {
                    self.apps = apps
                }
            case let .failure(error):
                api.handleError(error)
            }
            
            if selectedAppID == nil {
                selectedAppID = ((apps ?? []).sorted { $0.name < $1.name }).first?.id
            }

            self.isLoading = false
            callback?(result)
        }
    }

    func create(appNamed name: String, callback: ((Result<TelemetryApp, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps")

        api.post(["name": name], to: url) { [unowned self] (result: Result<TelemetryApp, TransferError>) in
            self.getApps()
            callback?(result)
        }
    }

    func update(appID: UUID, newName: String, callback: ((Result<TelemetryApp, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString)

        api.patch(["name": newName], to: url) { [unowned self] (result: Result<TelemetryApp, TransferError>) in
            self.getApps()
            callback?(result)
        }
    }

    func delete(appID: UUID, callback: ((Result<String, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString)

        api.delete(url) { [unowned self] (result: Result<String, TransferError>) in
            self.getApps()
            callback?(result)
            self.selectedAppID = nil
        }
    }
}
