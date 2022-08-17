//
//  Color.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 10.10.20.
//

import Foundation
import SwiftUI

extension Color {
    #if os(macOS)
        static let grayColor = Color(NSColor.systemGray)
        static let separatorColor = Color(NSColor.separatorColor)
    #else
        static let grayColor = Color(UIColor.systemGray)
        static let separatorColor = Color(UIColor.separator)
    #endif

    static let telemetryOrange = Color("Torange")
    static let cardBackground = Color("CardBackgroundColor")
    static let customTextColor = Color("CustomTextColor")
}
