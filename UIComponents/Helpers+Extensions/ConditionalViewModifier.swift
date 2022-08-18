//
//  ConditionalViewModifier.swift
//  Telemetry Viewer
//
//  Created by Charlotte Böhm on 04.11.21.
//

import Foundation
import SwiftUI

extension View {
  @ViewBuilder
  func `if`<Transform: View>(
    _ condition: Bool,
    transform: (Self) -> Transform
  ) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}
