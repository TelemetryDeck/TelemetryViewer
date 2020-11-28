//
//  DetailSidebar.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 24.11.20.
//

import SwiftUI

struct DetailSidebar<Content>: View where Content: View {
    private let content: Content
    private let maxWidth: CGFloat

    @Binding var isOpen: Bool

    public init(isOpen: Binding<Bool>, maxWidth: CGFloat, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.maxWidth = maxWidth
        self._isOpen = isOpen
    }

    var body: some View {
        HStack(spacing: 0) {
            #if os(macOS)
            #else
            Divider()
            #endif

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: maxWidth, maxHeight: .infinity)
    }
}

struct DetailSidebar_Previews: PreviewProvider {
    static var previews: some View {

        HStack {
            Color.blue
            DetailSidebar(isOpen: .constant(true), maxWidth: 500) {
                Color.green
            }
        }


    }
}
