//
//  Optional+Bound.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 20.10.20.
//

import Foundation

extension Optional where Wrapped == String {
    var _bound: String? {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
    public var bound: String {
        get {
            return _bound ?? ""
        }
        set {
            _bound = newValue.isEmpty ? nil : newValue
        }
    }
    
    public var irreversiblyBound: String {
        get {
            return _bound ?? ""
        }
        set {
            _bound = newValue
        }
    }
}
