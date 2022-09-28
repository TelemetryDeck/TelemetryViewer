//
//  WidgetFamily+Small.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.09.22.
//

import Foundation
import WidgetKit

extension WidgetFamily {
    var isSmall: Bool {
        switch self {
        case .systemSmall:
            return true
        case .accessoryCorner, .accessoryCircular, .accessoryRectangular, .accessoryInline:
            return true
        default:
            return false
        }
    }
    
    var isTiny: Bool {
        switch self {
        case .accessoryCorner, .accessoryCircular, .accessoryRectangular, .accessoryInline:
            return true
        default:
            return false
        }
    }
}
