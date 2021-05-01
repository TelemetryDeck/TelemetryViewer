//
//  MacSettingsView.swift
//  Telemetry Viewer (macOS)
//
//  Created by Daniel Jilg on 01.05.21.
//

import SwiftUI

struct MacSettingsView: View {
    private enum Tabs: Hashable {
        case user, organization
    }
    
    var body: some View {
        TabView {
            OrganizationSettingsView()
                .tabItem {
                    Label("Organization Settings", systemImage: "star")
                }
                .tag(Tabs.organization)
            UserSettingsView()
                .tabItem {
                    Label("User Settings", systemImage: "gear")
                }
                .tag(Tabs.user)
        }
        .frame(width: 375, height: 350)
    }
}

struct MacSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MacSettingsView()
    }
}
