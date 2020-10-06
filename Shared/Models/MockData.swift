//
//  MockData.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.09.20.
//

import Foundation

struct MockData {
    static let exampleOrganization: Organization = .init(name: "breakthesystem")
    
    static let app1: TelemetryApp = .init(id: UUID(), name: "Test App", organization: ["id":"123"], isMockData: true)
    static let app2: TelemetryApp = .init(id: UUID(), name: "Other Test App", organization: ["id":"123"], isMockData: true)
    
    static let examplePayload: [String: String] = [
        "isTestFlight": "true",
    ]
    
    static let signals: [Signal] = [
        .init(id: nil, receivedAt: "Date()", clientUser: "winsmith", type: "testSignal", payload: examplePayload),
        .init(id: nil, receivedAt: "Date()", clientUser: "winsmith", type: "testSignal", payload: examplePayload),
        .init(id: nil, receivedAt: "Date()", clientUser: "winsmith", type: "testSignal", payload: examplePayload),
        .init(id: nil, receivedAt: "Date()", clientUser: "winsmith", type: "testSignal", payload: examplePayload),
        .init(id: nil, receivedAt: "Date()", clientUser: "winsmith", type: "testSignal", payload: examplePayload),
        .init(id: nil, receivedAt: "Date()", clientUser: "winsmith", type: "testSignal", payload: examplePayload),
    ]
}





