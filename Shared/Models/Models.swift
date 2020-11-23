//
//  Models.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 09.08.20.
//

import Foundation

struct UserDataTransferObject: Codable, Identifiable {
    let id: UUID
    let organization: Organization?
    let firstName: String
    let lastName: String
    let email: String
    let isFoundingUser: Bool
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
    case number // Deprecated, use Raw instead
    case raw
    case barChart
    case lineChart
    case pieChart
}

enum InsightGroupByInterval: String, Codable {
    case hour
    case day
    case week
    case month
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
    
    /// If set, group and count found signals by this time interval. Incompatible with breakdownKey
    var groupBy: InsightGroupByInterval?

    /// How should this insight's data be displayed?
    var displayMode: InsightDisplayMode
    
    /// If true, the insight will be displayed bigger
    var isExpanded: Bool
}

struct InsightData: Codable {
    let xAxisValue: String
    let yAxisValue: String?
    
    enum CodingKeys: String, CodingKey {
        case xAxisValue
        case yAxisValue
    }
    
    private let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.usesGroupingSeparator = true
        return numberFormatter
    }()
    
    var yAxisNumber: NSNumber? {
        guard let yAxisValue = yAxisValue else { return NSNumber(value: 0) }
        return numberFormatter.number(from: yAxisValue)
    }
    
    var yAxisDouble: Double? {
        return yAxisNumber?.doubleValue
    }
    
    var yAxisString: String {
        guard let yAxisValue = yAxisValue else { return "0" }
        guard let yAxisNumber = yAxisNumber else { return yAxisValue }
        return numberFormatter.string(from: yAxisNumber) ?? yAxisValue
    }
    
    var xAxisDate: Date? {
        return Formatter.iso8601noFS.date(from: xAxisValue)
    }
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
    
    /// If set, group and count found signals by this time interval. Incompatible with breakdownKey
    var groupBy: InsightGroupByInterval?
    
    /// How should this insight's data be displayed?
    var displayMode: InsightDisplayMode
    
    /// Current Live Calculated Data
    let data: [InsightData]
    
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
    let xAxisValue: String
    let yAxisValue: Double
    
    init(insightData: InsightData) throws {
        self.xAxisValue = insightData.xAxisValue
        
        if let yAxisValue = insightData.yAxisDouble {
            self.yAxisValue = yAxisValue
        } else {
            throw ChartDataSet.DataError.insufficientData
        }
    }
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
    
    var localizedDescription: String {
        switch self {
        
        case .transferFailed:
            return "There was a communication error with the server. Please check your internet connection and try again later."
        case .decodeFailed:
            return "The server returned a message that this version of the app could not decode. Please check if there is an update to the app, or contact the developer."
        case .serverError(message: let message):
            return "The server returned this error message: \(message)"
        }
    }
}

struct ServerErrorDetailMessage: Codable {
    let detail: String
}

struct ServerErrorReasonMessage: Codable {
    let reason: String
}

struct PasswordChangeRequestBody: Codable {
    var oldPassword: String
    var newPassword: String
    var newPasswordConfirm: String
}

struct BetaRequestEmail: Codable, Identifiable, Equatable {
    let id: UUID
    let email: String
    let registrationToken: String
    let requestedAt: Date
    let sentAt: Date?
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

/// Represents a standing invitation to join an organization
struct OrganizationJoinRequest: Codable, Identifiable, Equatable {
    let id: UUID
    let registrationToken: String
}

/// Sent to the server to create a user belonging to the organization
struct OrganizationJoinRequestURLObject: Codable {
    var email: String
    var firstName: String
    var lastName: String
    var password: String
    let organizationID: UUID
    let organizationName: String
    let registrationToken: String
}

struct RegistrationRequestBody: Codable {
    var registrationToken: String = ""
    var organisationName: String = ""
    var userFirstName: String = ""
    var userLastName: String = ""
    var userEmail: String = ""
    var userPassword: String = ""
    var userPasswordConfirm: String = ""
    
    var isValid: Bool {
        return !organisationName.isEmpty && !userFirstName.isEmpty && !userLastName.isEmpty && !userEmail.isEmpty && !userPassword.isEmpty && !userPasswordConfirm.isEmpty
    }
}

struct LoginRequestBody {
    var userEmail: String = ""
    var userPassword: String = ""
    
    var basicHTMLAuthString: String? {
        let loginString = "\(userEmail):\(userPassword)"
        guard let loginData = loginString.data(using: String.Encoding.utf8) else { return nil }
        let base64LoginString = loginData.base64EncodedString()
        return "Basic \(base64LoginString)"
    }
    
    var isValid: Bool {
        return !userEmail.isEmpty && !userPassword.isEmpty
    }
}

struct UserToken: Codable {
    var id: UUID?
    var value: String
    var user: [String: String]
    
    var bearerTokenAuthString: String {
        return "Bearer \(value)"
    }
}

struct BetaRequestUpdateBody: Codable {
    let sentAt: Date?
    let isFulfilled: Bool
}

struct ChartDataSet {
    enum DataError: Error {
        case insufficientData
    }
    
    let data: [ChartDataPoint]
    let lowestValue: Double
    let highestValue: Double
    
    init(data: [InsightData]) throws {
        self.data = try data.map { try ChartDataPoint(insightData: $0) }
        
        self.highestValue = self.data.reduce(0, { max($0, $1.yAxisValue) })
        self.lowestValue = 0
    }
}
