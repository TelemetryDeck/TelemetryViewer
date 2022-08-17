//
//  URL+Open.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 13.04.21.
//

import Foundation
import SwiftUI

extension URL {
    func open() {
        #if os(macOS)
        NSWorkspace.shared.open(self)
        #else
        UIApplication.shared.open(self)
        #endif
    }
}
