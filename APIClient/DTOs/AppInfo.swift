//
//  AppInfo.swift
//  Telemetry Viewer (iOS)
//
//  Created by Lukas on 21.05.24.
//

import Foundation
import DataTransferObjects
import SwiftUI

public struct AppInfo: Codable, Hashable, Identifiable {
    public var id: UUID
    public var name: String
    public var organizationID: UUID
    public var insightGroups: [InsightGroupInfo]
    public var settings: DTOv2.AppSettings
    public var insightGroupIDs: [UUID] {
        insightGroups.map { group in
            group.id
        }
    }

}
