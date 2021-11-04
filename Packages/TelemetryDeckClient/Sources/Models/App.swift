import Foundation

class App: LocalModel {
    public var name: String
    public var organizationID: Organization.ID
    public var insightGroupIDs: [Group.ID]
}
