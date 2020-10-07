//
//  WelcomeView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.09.20.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Login to Telemetry").font(.largeTitle)
            
            HStack {
                LoginView()
                Rectangle()
                    .frame(maxWidth: 1)
                    .padding()
                RegisterButtonView()
            }
        }
        .padding()
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
