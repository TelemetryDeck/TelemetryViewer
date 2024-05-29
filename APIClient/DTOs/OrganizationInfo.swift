//
//  OrganizationInfo.swift
//  Telemetry Viewer
//
//  Created by Lukas on 29.05.24.
//

import Foundation
import SwiftUI

struct OrganizationInfo: Codable, Equatable {
    var id: UUID
    var name: String
    var stripeCustomerID: String?
    var stripeMaxSignals: Double?
    var maxSignalsMultiplier: Double?
    var resolvedMaxSignals: Int64
    var isInRestrictedMode: Bool
    var countryCode: String?
    var referralCode: String
    var usagePercentage: Double?
    var isSuperOrg: Bool
    var apps: [AppInfo]
    var basePermissions: AppAccessLevel
    var roleOrganizationPermissions: AppAccessLevel?

    var appIDs: [UUID] {
        apps.map { app in
            app.id
        }
    }

  }

public enum AppAccessLevel: String, Codable, Comparable {
    case none
    case read
    case write
    case administrate

    public static func < (lhs: AppAccessLevel, rhs: AppAccessLevel) -> Bool {
        switch lhs {
        case .none:
            switch rhs {
            case .none:
                false
            case .read:
                true
            case .write:
                true
            case .administrate:
                true
            }
        case .read:
            switch rhs {
            case .none:
                false
            case .read:
                false
            case .write:
                true
            case .administrate:
                true
            }
        case .write:
            switch rhs {
            case .none:
                false
            case .read:
                false
            case .write:
                false
            case .administrate:
                true
            }
        case .administrate:
            false
        }
    }
}
