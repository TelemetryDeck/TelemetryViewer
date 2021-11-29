//
//  APIObjectContext.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 27.11.21.
//

import Foundation

class APIObjectContext: ObservableObject {
    private let api: APIClient
    
    private var registeredObjects = [APIObjectContextManageable]()
    
    init(api: APIClient) {
        self.api = api
    }
    
    public func refresh() {
        // TODO: Download all that need download
    }
    
    public func save() {
        // TODO: Upload all that need upload
    }
    
    public func register(manageable: APIObjectContextManageable) {
        registeredObjects.removeAll { $0.id == manageable.id }
        registeredObjects.append(manageable)
    }
    
    public func deregister(manageable: APIObjectContextManageable) {
        registeredObjects.removeAll { $0.id == manageable.id }
    }
    
    public func object(ofType: String, withID: UUID) -> APIObjectContextManageable? {
        registeredObjects.first(where: { $0.id == withID && $0.type == ofType })
    }
}

protocol APIObjectContextManageable {
    var context: APIObjectContext { get }
    var id: UUID { get }
    var type: String { get }
    var apiURLPrefix: String { get }
    var codableRepresentation: Codable { get }
    
    /// If `true` this instance is waiting to upload changes to the server
    var needsUpload: Bool { get set }
    
    /// If `true`, this instance should update itself from the server
    var needsDownload: Bool { get set }
    
    var lastUploaded: Date { get set }
    var lastDownloaded: Date { get set }
}
