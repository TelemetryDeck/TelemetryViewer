//
//  MockData.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.09.20.
//

import Foundation

struct MockData {
    static let exampleOrganization: DTO.Organization = .init(id: UUID(), name: "breakthesystem", isSuperOrg: true)

    static let app1: TelemetryApp = .init(id: UUID(), name: "Test App", organization: ["id": "123"])
    static let app2: TelemetryApp = .init(id: UUID(), name: "Other Test App", organization: ["id": "123"])

    static let examplePayload: [String: String] = [
        "isTestFlight": "true",
    ]

    static let signals: [DTO.Signal] = [
        .init(id: nil, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
        .init(id: nil, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
        .init(id: nil, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
        .init(id: nil, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
        .init(id: nil, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
        .init(id: nil, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
    ]

    static let lexiconSignalTypes: [LexiconSignalTypeDTO] = [
        .init(id: UUID(), firstSeenAt: Date(), isHidden: false, type: "signalsUpdated"),
        .init(id: UUID(), firstSeenAt: Date(), isHidden: false, type: "testSignal"),
        .init(id: UUID(), firstSeenAt: Date(), isHidden: false, type: "pizzaModeActivated"),
        .init(id: UUID(), firstSeenAt: Date(), isHidden: true, type: "catTypeFeline"),
        .init(id: UUID(), firstSeenAt: Date(), isHidden: false, type: "appFirstLaunchedNormallyAndGotUserInteraction"),
        .init(id: UUID(), firstSeenAt: Date(), isHidden: false, type: "phoneRotated"),
    ]

    static let lexiconPayloadKeys: [DTO.LexiconPayloadKey] = [
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

    static let exampleInsight1 = InsightCalculationResult(
        id: UUID(),
        order: 12,
        title: "Users Today",
        subtitle: "Number of users seen in the last 24 hours",
        signalType: nil,
        uniqueUser: true,
        filters: [:],
        rollingWindowSize: -24 * 3600,
        breakdownKey: nil,
        displayMode: .raw,
        isExpanded: false,
        data: [InsightData(xAxisValue: "Todat", yAxisValue: "12323")],
        calculatedAt: Date(), calculationDuration: 1, shouldUseDruid: false
    )
}
