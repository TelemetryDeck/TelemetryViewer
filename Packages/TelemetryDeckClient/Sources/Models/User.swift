import Foundation

class User: LocalModel {
//    public let organization: DTOv1.Organization?
    public var firstName: String
    public var lastName: String
    public var email: String
    public let emailIsVerified: Bool
    public var receiveMarketingEmails: Bool?
    public let isFoundingUser: Bool
    public var receiveReports: ReportSendingRate
}
