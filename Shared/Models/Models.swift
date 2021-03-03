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
}

struct Signal: Codable, Hashable {
    var id: UUID?
    var receivedAt: Date
    var clientUser: String
    var type: String
    var payload: [String: String]?
}

struct InsightGroup: Codable, Identifiable, Hashable {
    var id: UUID
    var title: String
    var order: Double?
    var insights: [Insight] = []

    func getDTO() -> InsightGroupDTO {
        InsightGroupDTO(id: id, title: title, order: order)
    }

    static func == (lhs: InsightGroup, rhs: InsightGroup) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct InsightGroupDTO: Codable, Identifiable {
    var id: UUID
    var title: String
    var order: Double?
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

    /// The amount of time (in seconds) this query took to calculate last time
    var lastRunTime: TimeInterval?

    /// The query that was last used to run this query
    var lastQuery: String?

    /// The date this query was last run
    var lastRunAt: Date?

    /// Should use druid for calculating this insght
    var shouldUseDruid: Bool
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
        yAxisNumber?.doubleValue
    }

    var yAxisString: String {
        guard let yAxisValue = yAxisValue else { return "0" }
        guard let yAxisNumber = yAxisNumber else { return yAxisValue }
        return numberFormatter.string(from: yAxisNumber) ?? yAxisValue
    }

    var xAxisDate: Date? {
        Formatter.iso8601noFS.date(from: xAxisValue) ?? Formatter.iso8601.date(from: xAxisValue)
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

    /// How long did this DTO take to calculate?
    let calculationDuration: TimeInterval

    var isEmpty: Bool {
        data.compactMap(\.yAxisValue).count == 0
    }
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

    /// If set, group and count found signals by this time interval. Incompatible with breakdownKey
    var groupBy: InsightGroupByInterval?

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
            groupBy: insight.groupBy ?? .day,
            displayMode: insight.displayMode,
            groupID: insight.group["id"],
            id: insight.id,
            isExpanded: insight.isExpanded
        )

        return requestBody
    }

    static func new(groupID: UUID) -> InsightDefinitionRequestBody {
        InsightDefinitionRequestBody(
            order: nil,
            title: "New Insight",
            subtitle: nil,
            signalType: nil,
            uniqueUser: false,
            filters: [:],
            rollingWindowSize: -2_592_000,
            breakdownKey: nil,
            groupBy: .day,
            displayMode: .lineChart,
            groupID: groupID,
            id: nil,
            isExpanded: false
        )
    }
}

struct ChartDataPoint: Hashable, Identifiable {
    var id: String { xAxisValue }

    let xAxisValue: String
    let yAxisValue: Double

    init(insightData: InsightData) throws {
        xAxisValue = insightData.xAxisValue

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
        case let .serverError(message: message):
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
    let email: String
    let registrationToken: String
    let organization: [String: UUID]
}

/// Sent to the server to create a user belonging to the organization
struct OrganizationJoinRequestURLObject: Codable {
    var email: String
    var firstName: String
    var lastName: String
    var password: String
    let organizationID: UUID
    var registrationToken: String
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
        !organisationName.isEmpty && !userFirstName.isEmpty && !userEmail.isEmpty && !userPassword.isEmpty && !userPasswordConfirm.isEmpty && !userPassword.contains(":")
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
        !userEmail.isEmpty && !userPassword.isEmpty
    }
}

struct UserToken: Codable {
    var id: UUID?
    var value: String
    var user: [String: String]

    var bearerTokenAuthString: String {
        "Bearer \(value)"
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

        highestValue = self.data.reduce(0) { max($0, $1.yAxisValue) }
        lowestValue = 0
    }
}

struct OrganizationAdminListEntry: Codable, Identifiable {
    let id: UUID
    let name: String
    let foundedAt: Date
    let sumSignals: Int
    let isSuperOrg: Bool
    let firstName: String?
    let lastName: String?
    let email: String
}

struct AggregateDTO: Codable {
    let min: TimeInterval
    let avg: TimeInterval
    let max: TimeInterval
}

enum AppRootViewSelection: Hashable {
    case insightGroup(group: InsightGroup)
    case lexicon
    case rawSignals
    case noSelection
}
