//
//  CustomSection.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 27.11.20.
//

import SwiftUI

struct CustomSection<Content, Header, Footer>: View where Content: View, Header: View, Footer: View {
    let header: Header
    let footer: Footer
    let content: () -> Content

    @State private var isCollapsed: Bool = false
    @State private var isHovering = false

    public init(header: Header, footer: Footer, startCollapsed: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.header = header
        self.footer = footer
        self.content = content
        self.isCollapsed = startCollapsed
    }

    public var body: some View {
        #if os(macOS)
        VStack(alignment: .leading) {
            HStack {
                header
                    .font(Font.body.weight(.semibold))
                    .foregroundColor(.grayColor)

                Spacer()

                Image(systemName: isCollapsed ? "arrowtriangle.backward" : "arrowtriangle.down")
                    .opacity(isHovering ? 1 : 0)
            }
            .onTapGesture {
                withAnimation {
                    isCollapsed.toggle()
                }
            }

            if !isCollapsed {
                content()

                footer
                    .font(.footnote)
                    .foregroundColor(.grayColor)
            }
            
            Divider()
        }
        .onHover { hover in
            isHovering = hover
        }
        #else
        Section(header: header, footer: footer, content: content)
        #endif
    }
}
