//
//  LexiconService.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 12.05.21.
//

import DataTransferObjects
import Foundation
import SwiftUI

class LexiconService: ObservableObject {
    enum LexiconSortKey {
        case type
        case signalCount
        case userCount
        case sessionCount
    }
    
    @Published var lexiconSignals: [UUID: [DTOv1.LexiconSignalDTO]] = [:]
    @Published var lexiconPayloadKeys: [UUID: [DTOv1.LexiconPayloadKey]] = [:]
    @Published var loadingAppIDs = Set<UUID>()
    
    let api: APIClient
    
    init(api: APIClient) {
        self.api = api
    }
    
    func signalTypes(for appID: UUID, sortedBy: LexiconSortKey = .type) -> [DTOv1.LexiconSignalDTO] {
        (lexiconSignals[appID] ?? []).sorted { left, right in
            switch sortedBy {
            case .type:
                return left.type.lowercased() < right.type.lowercased()
            case .signalCount:
                return left.signalCount > right.signalCount
            case .userCount:
                return left.userCount > right.userCount
            case .sessionCount:
                return left.sessionCount > right.sessionCount
            }
        }
    }
    
    func signalTypes(for appID: UUID) -> [DTOv1.LexiconSignalDTO] {
        lexiconSignals[appID] ?? []
    }
    
    func payloadKeys(for appID: UUID) -> [DTOv1.LexiconPayloadKey] {
        lexiconPayloadKeys[appID] ?? []
    }
    
    func isLoading(appID: UUID) -> Bool {
        loadingAppIDs.contains(appID)
    }
    
    func getSignalTypes(for appID: UUID, callback: ((Result<[DTOv1.LexiconSignalDTO], TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "lexicon", "signaltypes")
        
        loadingAppIDs.insert(appID)

        api.get(url) { [unowned self] (result: Result<[DTOv1.LexiconSignalDTO], TransferError>) in
            switch result {
            case let .success(lexiconItems):
                self.lexiconSignals[appID] = lexiconItems
            case let .failure(error):
                api.handleError(error)
            }
            
            loadingAppIDs.remove(appID)
            callback?(result)
        }
    }
    
    func getPayloadKeys(for appID: UUID, callback: ((Result<[DTOv1.LexiconPayloadKey], TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "lexicon", "payloadkeys")
        
        loadingAppIDs.insert(appID)

        api.get(url) { [unowned self] (result: Result<[DTOv1.LexiconPayloadKey], TransferError>) in
            switch result {
            case let .success(lexiconItems):
                self.lexiconPayloadKeys[appID] = lexiconItems
            case let .failure(error):
                api.handleError(error)
            }

            loadingAppIDs.remove(appID)
            callback?(result)
        }
    }
    
   // /api/v3/app/<ID>/lexicon/payloadkeys
    
    func getPayloadKeysv2(for appID: UUID) async throws -> [DTOv2.LexiconPayloadKey] {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[DTOv2.LexiconPayloadKey], Error>) in
            let url = api.urlForPath(apiVersion: .v3, "apps", appID.uuidString, "lexicon", "payloadkeys")
            api.get(url) { (result: Result<[DTOv2.LexiconPayloadKey], TransferError>) in
                switch result {
                case let .success(lexiconPayloadKeys):
                    continuation.resume(returning: lexiconPayloadKeys)

                case let .failure(error):
                    // self.errorService.handle(transferError: error)

                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

class MockLexiconService: LexiconService {
    convenience init() {
        self.init(api: APIClient())
    }
    
    private lazy var signalTypes: [DTOv1.LexiconSignalDTO] = [
        .init(type: "testSignal", signalCount: Int.random(in: 0...100000), userCount: Int.random(in: 0...10000), sessionCount: Int.random(in: 0...100000)),
        .init(type: "testSignal2", signalCount: Int.random(in: 0...100000), userCount: Int.random(in: 0...10000), sessionCount: Int.random(in: 0...100000)),
        .init(type: "testSignal3", signalCount: Int.random(in: 0...100000), userCount: Int.random(in: 0...10000), sessionCount: Int.random(in: 0...100000)),
        .init(type: "testSignal4", signalCount: Int.random(in: 0...100000), userCount: Int.random(in: 0...10000), sessionCount: Int.random(in: 0...100000)),
        .init(type: "testSignal5", signalCount: Int.random(in: 0...100000), userCount: Int.random(in: 0...10000), sessionCount: Int.random(in: 0...100000)),
        .init(type: "testSignal6", signalCount: Int.random(in: 0...100000), userCount: Int.random(in: 0...10000), sessionCount: Int.random(in: 0...100000)),
        .init(type: "testSignal7", signalCount: Int.random(in: 0...100000), userCount: Int.random(in: 0...10000), sessionCount: Int.random(in: 0...100000)),
    ]
    
    override func signalTypes(for appID: UUID, sortedBy: LexiconService.LexiconSortKey = .type) -> [DTOv1.LexiconSignalDTO] {
        signalTypes.sorted { left, right in
            switch sortedBy {
            case .type:
                return left.type.lowercased() < right.type.lowercased()
            case .signalCount:
                return left.signalCount > right.signalCount
            case .userCount:
                return left.userCount > right.userCount
            case .sessionCount:
                return left.sessionCount > right.sessionCount
            }
        }
    }
}
