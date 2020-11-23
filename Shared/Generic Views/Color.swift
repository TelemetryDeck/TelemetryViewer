//
//  Color.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 10.10.20.
//

import Foundation
import SwiftUI

extension Color {
    #if os (macOS)
    static let grayColor = Color(NSColor.systemGray)
    #else
    static let grayColor = Color(UIColor.systemGray)
    #endif
}
