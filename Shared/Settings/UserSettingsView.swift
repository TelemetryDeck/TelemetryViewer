//
//  UserSettingsView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 07.09.20.
//

import SwiftUI

struct UserSettingsView: View {
    @EnvironmentObject var api: APIRepresentative
    
    var body: some View {
        if let user = api.user {
            
            VStack(alignment: .leading) {
                HStack {
                    Text("First Name")
                    Text(user.firstName).bold()
                }
                
                HStack {
                    Text("Last Name")
                    Text(user.lastName).bold()
                }
                
                HStack {
                    Text("Email")
                    Text(user.email).bold()
                }
                
                Button("Log Out") {
                    api.logout()
                }
            }
            .navigationTitle("User Settings")
            .onAppear {
                TelemetryManager().send(.userSettingsShown, for: api.user?.email)
            }
        }
    }
}
