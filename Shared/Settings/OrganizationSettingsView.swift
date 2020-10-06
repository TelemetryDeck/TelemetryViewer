//
//  OrganizationSettingsView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 07.09.20.
//

import SwiftUI
import TelemetryClient

struct OrganizationSettingsView: View {
    @EnvironmentObject var api: APIRepresentative
    @EnvironmentObject var telemetryManager: TelemetryManager
    
    var body: some View {
        
        if let user = api.user {
            Text("Hello, \(user.organization.name)!").navigationTitle("Organization Settings")
                .onAppear {
                    telemetryManager.send(TelemetrySignal.organizationSettingsShown.rawValue, for: api.user?.email)
                }
        }
    }
}

struct OrganizationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        OrganizationSettingsView()
    }
}
