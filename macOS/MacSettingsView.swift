//
//  MacSettingsView.swift
//  Telemetry Viewer (macOS)
//
//  Created by Daniel Jilg on 01.05.21.
//

import SwiftUI

struct MacSettingsView: View {
    private enum Tabs: Hashable {
        case user, organization, updates, pricing
    }
    
    var body: some View {
        TabView {
            UserSettingsView()
                .tabItem {
                    Label("User", systemImage: "person")
                }
                .tag(Tabs.user)
            UpdateSettingsView()
                .tabItem {
                    Label("Updates", systemImage: "arrow.down.app")
                }
                .tag(Tabs.updates)
        }
        .frame(width: 675, height: 680)
    }
}

struct MacSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MacSettingsView()
    }
}
