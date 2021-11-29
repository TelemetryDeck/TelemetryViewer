//
//  ObservableInsightGroup.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 26.11.21.
//

import DataTransferObjects
import Foundation

class ObservableInsightGroup: ObservableObject, APIObjectContextManageable {
    var context: APIObjectContext
    
    var type = "Group"
    var apiURLPrefix = "v2/groups/"
    
    var needsUpload: Bool = false
    var needsDownload: Bool = false
    var lastUploaded = Date.distantPast
    var lastDownloaded = Date.distantPast
    
    let id: UUID
    var title: String { willSet { propertyUpdatedLocally() }}
    var order: Double? { willSet { propertyUpdatedLocally() }}
    var appID: DTOv2.App.ID { willSet { propertyUpdatedLocally() }}
    
    var codableRepresentation: Codable {
        DTOv2.Group(
            id: self.id,
            title: self.title,
            order: self.order,
            appID: self.appID,
            insightIDs: []
        )
    }

    private var insightIDs: [DTOv2.Insight.ID] { didSet { updateInsights() }}
    @Published public private(set) var insights: [DTOv2.Insight] = []

    init(insightGroupDTO: DTOv2.Group, context: APIObjectContext) {
        self.context = context
        self.id = insightGroupDTO.id
        self.title = insightGroupDTO.title
        self.order = insightGroupDTO.order
        self.appID = insightGroupDTO.appID
        self.insightIDs = insightGroupDTO.insightIDs
        
        self.context.register(manageable: self)
    }
    
    func propertyUpdatedLocally() {
        self.needsUpload = true
        objectWillChange.send()
    }
    
    private func updateInsights() {
        for insightID in insightIDs {
            // do we have the insight locally?
            if insights.first(where: { $0.id == insightID }) != nil { continue }
            
            // does the context have the insight?
            if let insightObject = context.object(ofType: "Insight", withID: insightID),
               let insight = insightObject as? DTOv2.Insight
            {
                insights.append(insight)
                continue
            }
            
            // nope, we'll have to download it 
        }
    }
}
