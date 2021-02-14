//
//  Optional+Bound.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 20.10.20.
//

import Foundation

public extension Optional where Wrapped == String {
    internal var _bound: String? {
        get {
            self
        }
        set {
            self = newValue
        }
    }

    var bound: String {
        get {
            _bound ?? ""
        }
        set {
            _bound = newValue.isEmpty ? nil : newValue
        }
    }

    var irreversiblyBound: String {
        get {
            _bound ?? ""
        }
        set {
            _bound = newValue
        }
    }
}
