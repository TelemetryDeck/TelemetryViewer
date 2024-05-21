//
//  UserInfo.swift
//  Telemetry Viewer (iOS)
//
//  Created by Lukas on 21.05.24.
//

import Foundation
import DataTransferObjects

struct UserInfoDTO: Identifiable, Codable {
    public let id: UUID
    public var firstName: String
    public var lastName: String
    public var email: String
    public let emailIsVerified: Bool
    public var receiveMarketingEmails: Bool?
    public var receiveReports: ReportSendingRate


}
