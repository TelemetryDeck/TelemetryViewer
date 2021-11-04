import Foundation

class Organization: LocalModel {
    public var name: String
    public var createdAt: Date?
    public var updatedAt: Date?
    public var isSuperOrg: Bool
    public var stripeMaxSignals: Int64?
    public var maxSignalsMultiplier: Double?
    public var resolvedMaxSignals: Int64
    public var isInRestrictedMode: Bool
    public var appIDs: [DTOv2.App.ID]
    public var badgeAwardIDs: [DTOv2.BadgeAward.ID]
}
