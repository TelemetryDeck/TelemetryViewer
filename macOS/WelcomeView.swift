//
//  WelcomeView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.09.20.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to Telemetry, Lightweight Analytics That's Not Evil")
                Text("Telemetry is a new service that helps app and web developers improve their product by supplying immediate, accurate telemetry data while users use your app. And the best part: It's all anonymized so your user's data stays private!").font(.footnote)
            }
            
        }
//        
//        VStack(alignment: .leading) {
//            Text("Welcome to Telemetry").font(.largeTitle)
//            
//            HStack {
//                LoginView()
//                Rectangle()
//                    .foregroundColor(.grayColor)
//                    .frame(maxWidth: 1)
//                    .padding()
//                RegisterButtonView()
//            }
//        }
//        .padding()
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
