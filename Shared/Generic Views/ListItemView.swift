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

    public init(background: Color = Color.grayColor.opacity(0.2), @ViewBuilder content: () -> Content) {
        self.backgroundColor = background
        self.content = content()
    }

    var body : some View {
        HStack {
            content
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .background(backgroundColor)
        .cornerRadius(15)
    }
}
