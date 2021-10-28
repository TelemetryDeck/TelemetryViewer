//
//  Telemetry
//
//  Created by Daniel Jilg on 27.11.19.
//  Copyright © 2019 breakthesystem. All rights reserved.
//

#if canImport(TelemetryClient)
import SwiftUI
import TelemetryClient

enum TelemetrySignal: String {
    case appLaunchedRegularly
    case telemetryAppCreated
    case telemetryAppUpdated
    case telemetryAppDeleted
    case telemetryAppUsersShown
    case telemetryAppInsightsShown
    case telemetryAppInsightsRefreshed
    case telemetryAppSignalsShown
    case telemetryAppSettingsShown
    case userSettingsShown
    case organizationSettingsShown
    case insightUpdatedAutomatically
    case insightUpdatedManually
    case insightUpdatedFirstTime
    case userLogin
    case userLogout
}
#endif
