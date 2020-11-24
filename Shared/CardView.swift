//
//  CardView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 02.09.20.
//

import SwiftUI

struct CardView<Content>: View where Content: View {
    private let content: Content
    private var isSelected: Bool

    public init(selected: Bool = false, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.isSelected = selected
    }

    var body : some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color("CardBackgroundColor"))
                .shadow(color: Color(hue: 0, saturation: 0, brightness: 0, opacity: 0.1), radius: 5, x: 0, y: 3)
            
            content
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.accentColor, lineWidth: isSelected ? 5 : 0)
        )
        .padding()
    }
}
