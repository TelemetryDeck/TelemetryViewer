//
//  ObservableOrganization.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 27.11.21.
//

import Foundation
import DataTransferObjects

class ObservableOrganization: APIObjectContextManageable, ObservableObject {
    var context: APIObjectContext
    
    var id: UUID
    var type: String { "Organization" }
    var apiURLPrefix: String { "v2/organization" }
    
    var codableRepresentation: Codable {
        DTOv2.Organization(
            id: self.id,
            name: <#T##String#>, createdAt: <#T##Date?#>, updatedAt: <#T##Date?#>, isSuperOrg: <#T##Bool#>, stripeCustomerID: <#T##String?#>, stripeMaxSignals: <#T##Int64?#>, maxSignalsMultiplier: <#T##Double?#>, resolvedMaxSignals: <#T##Int64#>, isInRestrictedMode: <#T##Bool#>, appIDs: <#T##[DTOv2.App.ID]#>, badgeAwardIDs: <#T##[DTOv2.BadgeAward.ID]#>)
    }
    
    var needsUpload: Bool
    
    var needsDownload: Bool
    
    var lastUploaded: Date
    
    var lastDownloaded: Date
    
    init(dto: DTOv2.Organization, context: APIObjectContext) {
        self.context = context
        self.id = dto.id
        
        
        self.context.register(manageable: self)
    }
}
