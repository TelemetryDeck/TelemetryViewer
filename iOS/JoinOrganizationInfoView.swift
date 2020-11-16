//
//  RegisterButtonView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.09.20.
//

import SwiftUI

struct JoinOrganizationInfoView: View {
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            Text("Every app that sends data to Telemetry belongs to an organization.")
            Text("Once you create an organization, you become its first administrator and can invite more people.")
            Text("If you want to join an existing organization, ask the organization's creator to send you an invitation link.")
            Text("Tap the invitation link on this device to join the organization.")
            Spacer()

        }
        .padding()
        .navigationTitle("Joining?")
        
    }
}

struct RegisterButtonView_Previews: PreviewProvider {
    static var previews: some View {
        JoinOrganizationInfoView()
    }
}
