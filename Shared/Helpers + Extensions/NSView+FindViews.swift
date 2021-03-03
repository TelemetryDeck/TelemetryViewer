//
//  NSView+FindViews.swift
//  Telemetry Viewer (iOS)
//
//  Created by Daniel Jilg on 03.03.21.
//

import SwiftUI

extension NSView {
    func findViews<T: NSView>(subclassOf _: T.Type) -> [T] {
        recursiveSubviews.compactMap { $0 as? T }
    }

    var recursiveSubviews: [NSView] {
        subviews + subviews.flatMap(\.recursiveSubviews)
    }
}
