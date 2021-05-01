//
//  ProgressView+Scale.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 01.05.21.
//

import Foundation
import SwiftUI

#if os(iOS)
let progressViewScale: CGFloat = 0.5
let progressViewScaleLarge: CGFloat = 1.0
#else
let progressViewScale: CGFloat = 0.25
let progressViewScaleLarge: CGFloat = 0.5
#endif
