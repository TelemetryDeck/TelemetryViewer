//
//  SidebarContainer.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 01.12.20.
//

import SwiftUI

struct SidebarContainer<MainContent, SidebarContent>: View where MainContent: View, SidebarContent: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var sizeClass
    #endif

    let mainContent: () -> MainContent
    let sidebarContent: () -> SidebarContent

    init(mainContent: @escaping () -> MainContent, sidebarContent: @escaping () -> SidebarContent) {
        self.mainContent = mainContent
        self.sidebarContent = sidebarContent
    }
    
    var body: some View {
        #if os(iOS)
        HStack(spacing: 0) {
            mainContent()
            sidebarContent()
        }
        #else
        HStack(spacing: 0) {
            mainContent()
            sidebarContent()
        }
        #endif
    }
}

struct SidebarContainer_Previews: PreviewProvider {
    static var previews: some View {
        SidebarContainer(mainContent: { Color.red }, sidebarContent: { Color.green })
    }
}

struct SidebarNavigationLink<Label, Destination>: View where Label: View, Destination: View {
    let destination: () -> Destination
    let label: () -> Label

    var body: some View {
        NavigationLink(
            destination: destination(),
            label: {
                label()
            })
    }
}
