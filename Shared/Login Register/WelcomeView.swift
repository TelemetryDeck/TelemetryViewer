//
//  WelcomeView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.09.20.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        
        VStack {
            AdaptiveStack {
                LoginView()
                RegisterButtonView()
            }
        }
        .navigationTitle("Login to Telemetry")
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
