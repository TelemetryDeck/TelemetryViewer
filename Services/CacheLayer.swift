//
//  CacheLayer.swift
//  CacheLayer
//
//  Created by Daniel Jilg on 17.08.21.
//

import Foundation

class CacheLayer: ObservableObject {
    private let queue: DispatchQueue = .init(label: "CacheLayer")
    
    let organizationCache = Cache<String, DTOsWithIdentifiers.Organization>(entryLifetime: 15 * 60)
    
}
