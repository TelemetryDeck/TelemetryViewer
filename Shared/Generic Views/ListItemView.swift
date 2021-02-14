//
//  CardView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 02.09.20.
//

import SwiftUI

struct ListItemView<Content>: View where Content: View {
    private let content: Content
    private let backgroundColor: Color
    private let spacing: CGFloat?
    private var isSelected: Bool

    public init(selected: Bool = false, background: Color = Color.grayColor.opacity(0.2), spacing: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        isSelected = selected
        backgroundColor = background
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        HStack(spacing: spacing) {
            content
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .background(backgroundColor)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.accentColor, lineWidth: isSelected ? 5 : 0)
        )
    }
}
