//
//  GeometryReader+SizeClasses.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.09.22.
//

import Foundation
import SwiftUI

extension GeometryProxy {
    var isSmallWidth: Bool {
        return self.size.width < 200
    }
    
    var isSmallHeight: Bool {
        return self.size.height < 200
    }
    
    var isTinyWidth: Bool {
        return self.size.width < 160
    }
    
    var isTinyHeight: Bool {
        return self.size.height < 80
    }
}
