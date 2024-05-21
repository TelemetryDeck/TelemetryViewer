//
//  InsightGroupInfo.swift
//  Telemetry Viewer (iOS)
//
//  Created by Lukas on 21.05.24.
//

import Foundation

public struct InsightGroupInfo: Codable, Hashable, Identifiable {
    public init(id: UUID, title: String, order: Double? = nil, appID: UUID, insights: [InsightInfo]) {
        self.id = id
        self.title = title
        self.order = order
        self.appID = appID
        self.insights = insights
    }

    public var id: UUID
    public var title: String
    public var order: Double?
    public var appID: UUID
    public var insights: [InsightInfo]

}
