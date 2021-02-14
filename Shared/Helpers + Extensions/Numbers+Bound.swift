//
//  Numbers+Bound.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 20.10.20.
//

import Foundation

extension Double {
    var stringValue: String {
        get {
            NumberFormatter().string(from: NSNumber(value: self)) ?? "–"
        }

        set {
            self = NumberFormatter().number(from: newValue)?.doubleValue ?? -1
        }
    }
}
