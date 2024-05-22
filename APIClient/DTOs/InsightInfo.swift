//
//  InsightInfo.swift
//  Telemetry Viewer (iOS)
//
//  Created by Lukas on 21.05.24.
//

import Foundation
import DataTransferObjects

public struct InsightInfo: Codable, Hashable, Identifiable {
    public enum InsightType: String, Codable, Hashable {
        case timeseries
        case topN
        case customQuery
        case funnel
        case experiment
    }

    public var id: UUID
    public var groupID: UUID

    /// order in which insights appear in the apps (if not expanded)
    public var order: Double?
    public var title: String

    /// What kind of insight is this?
    public var type: InsightType

    /// If set, display the chart with this accent color, otherwise fall back to default color
    public var accentColor: String?

    /// If set, use the custom query in this property instead of constructing a query out of the options below
    public var customQuery: CustomQuery?

    /// Which signal types are we interested in? If nil, do not filter by signal type
    public var signalType: String?

    /// If true, only include at the newest signal from each user
    public var uniqueUser: Bool

    /// If set, break down the values in this key
    public var breakdownKey: String?

    /// If set, group and count found signals by this time interval. Incompatible with breakdownKey
    public var groupBy: QueryGranularity?

    /// How should this insight's data be displayed?
    public var displayMode: InsightDisplayMode

    /// If true, the insight will be displayed bigger
    public var isExpanded: Bool

    /// The amount of time (in seconds) this query took to calculate last time
    public var lastRunTime: TimeInterval?

    /// The date this query was last run
    public var lastRunAt: Date?

    public init(
        id: UUID,
        groupID: UUID,
        order: Double?,
        title: String,
        type: InsightType,
        accentColor: String? = nil,
        widgetable _: Bool? = false,
        customQuery: CustomQuery? = nil,
        signalType: String?,
        uniqueUser: Bool,
        breakdownKey: String?,
        groupBy: QueryGranularity?,
        displayMode: InsightDisplayMode,
        isExpanded: Bool,
        lastRunTime: TimeInterval?,
        lastRunAt: Date?
    ) {
        self.id = id
        self.groupID = groupID
        self.order = order
        self.title = title
        self.type = type
        self.accentColor = accentColor
        self.customQuery = customQuery
        self.signalType = signalType
        self.uniqueUser = uniqueUser
        self.breakdownKey = breakdownKey
        self.groupBy = groupBy
        self.displayMode = displayMode
        self.isExpanded = isExpanded
        self.lastRunTime = lastRunTime
        self.lastRunAt = lastRunAt
    }
}
