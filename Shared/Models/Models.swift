//
//  Models.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 09.08.20.
//

import Foundation

struct UserDataTransferObject: Codable {
    let id: UUID
    let organization: Organization?
    let firstName: String
    let lastName: String
    let email: String
}

struct Organization: Codable, Hashable {
    var id: UUID?
    var name: String
    var isSuperOrg: Bool
}

struct TelemetryApp: Codable, Hashable, Identifiable {
    var id: UUID
    var name: String
    var organization: [String: String]
    var isMockData: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id, name, organization
    }
}

struct Signal: Codable, Hashable {
    var id: UUID?
    var receivedAt: Date
    var clientUser: String
    var type: String
    var payload: Dictionary<String, String>?
}

struct InsightGroup: Codable, Identifiable {
    var id: UUID
    var title: String
    var order: Double?
    var insights: [Insight] = []
}

enum InsightDisplayMode: String, Codable {
    case number
    case barChart
    case lineChart
    case pieChart
}

struct Insight: Codable, Identifiable {
    var id: UUID
    var group: [String: UUID]
    
    var order: Double?
    var title: String
    var subtitle: String?
    
    /// Which signal types are we interested in? If nil, do not filter by signal type
    var signalType: String?
    
    /// If true, only include at the newest signal from each user
    var uniqueUser: Bool
    
    /// Only include signals that match all of these key-values in the payload
    var filters: [String: String]
    
    /// How far to go back to aggregate signals
    var rollingWindowSize: TimeInterval
    
    /// If set, break down the values in this key
    var breakdownKey: String?

    /// How should this insight's data be displayed?
    var displayMode: InsightDisplayMode
    
    /// If true, the insight will be displayed bigger
    var isExpanded: Bool
}

struct InsightDataTransferObject: Codable {
    let id: UUID
    
    let order: Double?
    let title: String
    let subtitle: String?
    
    /// Which signal types are we interested in? If nil, do not filter by signal type
    let signalType: String?
    
    /// If true, only include at the newest signal from each user
    let uniqueUser: Bool
    
    /// Only include signals that match all of these key-values in the payload
    let filters: [String: String]
    
    /// How far to go back to aggregate signals
    let rollingWindowSize: TimeInterval
    
    /// If set, break down the values in this key
    var breakdownKey: String?
    
    /// How should this insight's data be displayed?
    var displayMode: InsightDisplayMode
    
    /// Current Live Calculated Data
    let data: [[String: String]]
    
    /// When was this DTO calculated?
    let calculatedAt: Date
}

struct InsightDefinitionRequestBody: Codable {
    var order: Double?
    var title: String
    var subtitle: String?
    
    /// Which signal types are we interested in? If nil, do not filter by signal type
    var signalType: String?
    
    /// If true, only include at the newest signal from each user
    var uniqueUser: Bool
    
    /// Only include signals that match all of these key-values in the payload
    var filters: [String: String]
    
    /// How far to go back to aggregate signals
    var rollingWindowSize: TimeInterval
    
    /// If set, break down the values in this key
    var breakdownKey: String?
    
    /// How should this insight's data be displayed?
    var displayMode: InsightDisplayMode
    
    /// Which group should the insight belong to? (Only use this in update mode)
    var groupID: UUID?
    
    /// The ID of the insight. Not changeable, only set in update mode
    var id: UUID?
    
    /// If true, the insight will be displayed bigger
    var isExpanded: Bool
    
    static func from(insight: Insight) -> InsightDefinitionRequestBody {
        let requestBody = Self(
            order: insight.order,
            title: insight.title,
            subtitle: insight.subtitle,
            signalType: insight.signalType,
            uniqueUser: insight.uniqueUser,
            filters: insight.filters,
            rollingWindowSize: insight.rollingWindowSize,
            breakdownKey: insight.breakdownKey,
            displayMode: insight.displayMode,
            groupID: insight.group["id"],
            id: insight.id,
            isExpanded: insight.isExpanded)
        
        return requestBody
    }
}

struct ChartDataPoint: Hashable {
    let date: Date
    let value: Double
}

enum RegistrationStatus: String, Codable {
    case closed
    case tokenOnly
    case open
}

enum TransferError: Error {
    case transferFailed
    case decodeFailed
    case serverError(message: String)
}

struct ServerErrorMessage: Codable {
    let detail: String
}

struct PasswordChangeRequestBody: Codable {
    var oldPassword: String
    var newPassword: String
    var newPasswordConfirm: String
}

struct BetaRequestEmail: Codable, Identifiable {
    let id: UUID
    let email: String
    let registrationToken: String
    let requestedAt: Date
    let isFulfilled: Bool
}

struct LexiconSignalType: Codable, Identifiable {
    let id: UUID
    let firstSeenAt: Date

    /// If true, don't include this lexicon item in autocomplete lists
    let isHidden: Bool
    let type: String
}

struct LexiconPayloadKey: Codable, Identifiable {
    let id: UUID
    let firstSeenAt: Date

    /// If true, don't include this lexicon item in autocomplete lists
    let isHidden: Bool
    let payloadKey: String
}

