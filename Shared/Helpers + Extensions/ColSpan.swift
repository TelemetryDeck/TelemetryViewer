//
//  ColSpan.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 22.10.20.
//

import Foundation
import SwiftUI

struct ColSpan<Content: View>: View {
    let span: Bool
    let content: () -> Content
    
    init(span: Bool, @ViewBuilder content: @escaping () -> Content) {
        self.span = span
        self.content = content
    }
    
    var body: some View {
        content()
        
        if span { Color.clear }
    }
}
