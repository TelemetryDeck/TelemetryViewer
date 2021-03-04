//
//  View+toggleSidebar.swift
//  Telemetry Viewer (iOS)
//
//  Created by Daniel Jilg on 03.03.21.
//

import SwiftUI

extension View {
    func getSplitViewItems() -> [NSSplitViewItem]? {
        guard
            let mainView = NSApp.keyWindow?.contentView,
            let splitView = mainView.findViews(subclassOf: NSSplitView.self).first,
            let splitViewItems = (splitView.delegate as? NSSplitViewController)?.splitViewItems
        else { return nil }

        return splitViewItems
    }

    func getRightSidebarSplitViewItem() -> NSSplitViewItem? {
        guard
            let splitViewItems = getSplitViewItems(),
            let rightMostSplitItem = splitViewItems.last
        else { return nil }

        return rightMostSplitItem
    }

    func toggleRightSidebar() {
        getRightSidebarSplitViewItem()?.animator().isCollapsed.toggle()
    }

    func expandRightSidebar() {
        getRightSidebarSplitViewItem()?.animator().isCollapsed = false
    }

    func setupSidebars() {
        guard let splitViewItems = getSplitViewItems() else { return }

        splitViewItems.forEach { $0.minimumThickness = 250 }
        splitViewItems.last?.maximumThickness = 250
    }
}
