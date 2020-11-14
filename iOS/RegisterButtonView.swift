//
//  RegisterButtonView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.09.20.
//

import SwiftUI

struct RegisterButtonView: View {
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            Text("Want to Create a New Organization?").font(.title2)
            Text("Every app that sends data to Telemetry belongs to an organization.")
            Text("Once you create an organization, you become its first administrator and can invite more people.")
            Text("If you want to join an existing organization, ask the organization's creator to send you an invitation code.")
            
            NavigationLink(
                destination: RegisterView(),
                label: {
                    Label("Register an Organisation", systemImage: "star.square.fill")
                }
            )
        }.padding()
        
    }
}

struct RegisterButtonView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterButtonView()
    }
}
