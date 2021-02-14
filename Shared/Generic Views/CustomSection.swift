//
//  CustomSection.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 27.11.20.
//

import SwiftUI

struct CustomSection<Content, Header, Summary, Footer>: View where Content: View, Header: View, Summary: View, Footer: View {
    let header: Header
    let summary: Summary
    let footer: Footer
    let content: () -> Content

    @State private var isCollapsed: Bool = false
    @State private var isHovering = false

    public init(header: Header, summary: Summary, footer: Footer, startCollapsed: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.header = header
        self.summary = summary
        self.footer = footer
        self.content = content
        _isCollapsed = State(initialValue: startCollapsed)
    }

    public var body: some View {
        #if os(macOS)
            Section {
                VStack(alignment: .leading) {
                    HStack {
                        header
                            .font(Font.body.weight(.bold))
                            .opacity(0.7)

                        Spacer()

                        summary
                            .opacity(0.4)

                        if isHovering {
                            Image(systemName: isCollapsed ? "chevron.left" : "chevron.down")
                        }
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
            }
            .onHover { hover in
                isHovering = hover
            }
        #else
            Section(header: header, footer: footer, content: content)
        #endif
    }
}
