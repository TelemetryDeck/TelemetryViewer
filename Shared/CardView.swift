//
//  CardView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 02.09.20.
//

import SwiftUI

struct CardView<Content>: View where Content: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body : some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(Color("CardBackgroundColor"))
                .shadow(color: Color(hue: 0, saturation: 0, brightness: 0, opacity: 0.2), radius: 7, x: 0, y: 6)
            
            content
        }
        .padding()
    }
}
