//
//  StatusMessageContainer.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 26.10.21.
//

import SwiftUI

struct StatusMessageContainer<Content>: View where Content: View {
    private let content: Content
    private let backgroundColor: Color

    public init(backgroundColor: Color, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        content
            .padding(.horizontal)
            .padding(.vertical, 5)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding()
    }
}
