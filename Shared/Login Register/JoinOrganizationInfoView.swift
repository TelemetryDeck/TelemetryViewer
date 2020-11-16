//
//  RegisterButtonView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.09.20.
//

import SwiftUI

struct JoinOrganizationInfoView: View {
    var body: some View {
        
        let stack = VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()
                
                Image("analyzing_process")
                    .resizable()
                    .scaledToFit()
                Spacer()
            }
            .padding(.bottom)
            
            Text("Every app that sends data to Telemetry belongs to an organization.")
            Text("Once you create an organization, you become its first administrator and can invite more people.")
            Text("If you want to join an existing organization, ask the organization's creator to send you an invitation link.")
            Text("Tap the invitation link on this device to join the organization.")
            
            Spacer()

        }
        .navigationTitle("Joining?")
        
        #if os(macOS)
        stack
        #else
        stack.padding()
        #endif
    }
}

struct RegisterButtonView_Previews: PreviewProvider {
    static var previews: some View {
        JoinOrganizationInfoView()
    }
}
