//
//  ObservableInsight.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 26.11.21.
//

import DataTransferObjects
import Foundation

class ObservableInsight: ObservableAPIObject {
    public let groupID: UUID
    public var order: Double
    public var title: String

    /// If set, display the chart with this accent color, otherwise fall back to default color
    public var accentColor: String? { willSet { propertyUpdatedLocally() }}

    /// If set, use the custom query in this property instead of constructing a query out of the options below
    public var druidCustomQuery: DruidCustomQuery? { willSet { propertyUpdatedLocally() }}

    /// Which signal types are we interested in? If nil, do not filter by signal type
    public var signalType: String? { willSet { propertyUpdatedLocally() }}

    /// If true, only include at the newest signal from each user
    public var uniqueUser: Bool { willSet { propertyUpdatedLocally() }}

    /// Only include signals that match all of these key-values in the payload
    public var filters: [String: String] { willSet { propertyUpdatedLocally() }}

    /// If set, break down the values in this key
    public var breakdownKey: String? { willSet { propertyUpdatedLocally() }}

    /// If set, group and count found signals by this time interval. Incompatible with breakdownKey
    public var groupBy: InsightGroupByInterval? { willSet { propertyUpdatedLocally() }}

    /// How should this insight's data be displayed?
    public var displayMode: InsightDisplayMode { willSet { propertyUpdatedLocally() }}

    /// If true, the insight will be displayed bigger
    public var isExpanded: Bool { willSet { propertyUpdatedLocally() }}

    /// The amount of time (in seconds) this query took to calculate last time
    @Published public private(set) var lastRunTime: TimeInterval?

    /// The date this query was last run
    @Published public private(set) var lastRunAt: Date?

    init(insightDTO: DTOv2.Insight, apiClient: QueuedAPIClient) {
        self.groupID = insightDTO.groupID

        self.order = insightDTO.order ?? 0
        self.title = insightDTO.title
        self.accentColor = insightDTO.accentColor
        self.druidCustomQuery = insightDTO.druidCustomQuery
        self.signalType = insightDTO.signalType
        self.uniqueUser = insightDTO.uniqueUser
        self.filters = insightDTO.filters
        self.breakdownKey = insightDTO.breakdownKey
        self.groupBy = insightDTO.groupBy
        self.displayMode = insightDTO.displayMode
        self.isExpanded = insightDTO.isExpanded
        self.lastRunTime = insightDTO.lastRunTime
        self.lastRunAt = insightDTO.lastRunAt

        super.init(id: insightDTO.id, apiClient: apiClient)
    }

    private func update(with insightDTO: DTOv2.Insight) {
        self.order = insightDTO.order ?? 0
        self.title = insightDTO.title
        self.accentColor = insightDTO.accentColor
        self.druidCustomQuery = insightDTO.druidCustomQuery
        self.signalType = insightDTO.signalType
        self.uniqueUser = insightDTO.uniqueUser
        self.filters = insightDTO.filters
        self.breakdownKey = insightDTO.breakdownKey
        self.groupBy = insightDTO.groupBy
        self.displayMode = insightDTO.displayMode
        self.isExpanded = insightDTO.isExpanded
        self.lastRunTime = insightDTO.lastRunTime
        self.lastRunAt = insightDTO.lastRunAt
    }

    // TODO: auto-update from server every hour
    // TODO: auto-update changes to server, and invalidate data if that happens
    // TODO: download data on request, in queue
    // TODO: Allow changing groups
    // TODO: Save manually?
    // TODO: Property wrapper for updating properties
}
