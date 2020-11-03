//
//  Helpers.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 03.11.20.
//

import Foundation
import SwiftUI

func saveToClipBoard(_ clipString: String) {
    #if os(macOS)
    NSPasteboard.general.declareTypes([.string], owner: nil)
    NSPasteboard.general.setString(clipString, forType: .string)
    #else
    UIPasteboard.general.string = clipString
    #endif
}
