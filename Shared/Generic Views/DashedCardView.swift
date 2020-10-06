//
//  CardView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 02.09.20.
//

import SwiftUI

struct DashedCardView<Content>: View where Content: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body : some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 4, dash: [10]))
                .opacity(0.4)
                
                
            
            content
            .padding()
        }
        .padding()
    }
}
