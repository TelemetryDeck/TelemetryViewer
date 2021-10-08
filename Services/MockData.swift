//
//  MockData.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.09.20.
//

import Foundation

struct MockData {
    static let exampleOrganization: DTOv1.Organization = .init(id: UUID(), name: "breakthesystem", isSuperOrg: true, createdAt: Date(), updatedAt: Date())

    static let app1: TelemetryApp = .init(id: UUID(), name: "Test App", organization: ["id": "123"])
    static let app2: TelemetryApp = .init(id: UUID(), name: "Other Test App", organization: ["id": "123"])

    static let examplePayload: [String: String] = [
        "isTestFlight": "true",
    ]

    static let signals: [DTOv1.Signal] = [
        .init(receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
        .init(receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
        .init(receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
        .init(receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
        .init(receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
        .init(receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
    ]

    static let lexiconPayloadKeys: [DTOv1.LexiconPayloadKey] = [
        .init(id: UUID(), firstSeenAt: Date(), isHidden: false, payloadKey: "browser"),
        .init(id: UUID(), firstSeenAt: Date(), isHidden: false, payloadKey: "platform"),
        .init(id: UUID(), firstSeenAt: Date(), isHidden: false, payloadKey: "operatingSystem"),
        .init(id: UUID(), firstSeenAt: Date(), isHidden: false, payloadKey: "numberOfEntriesInDatabase"),
        .init(id: UUID(), firstSeenAt: Date(), isHidden: false, payloadKey: "isTestFlight"),
        .init(id: UUID(), firstSeenAt: Date(), isHidden: true, payloadKey: "isAppStore"),
        .init(id: UUID(), firstSeenAt: Date(), isHidden: false, payloadKey: "isSimulator"),
        .init(id: UUID(), firstSeenAt: Date(), isHidden: false, payloadKey: "numberOfRestarts"),
        .init(id: UUID(), firstSeenAt: Date(), isHidden: true, payloadKey: "appVersion"),
        .init(id: UUID(), firstSeenAt: Date(), isHidden: false, payloadKey: "systemVersion"),
    ]

    static let exampleInsight1 = DTOv1.InsightCalculationResult(
        id: UUID(),
        order: 12,
        title: "Users Today",
        signalType: nil,
        uniqueUser: true,
        filters: [:],
        rollingWindowSize: -24 * 3600,
        breakdownKey: nil,
        displayMode: .raw,
        isExpanded: false,
        data: [DTOv1.InsightData(xAxisValue: "Todat", yAxisValue: "12323")],
        calculatedAt: Date(), calculationDuration: 1
    )
}
