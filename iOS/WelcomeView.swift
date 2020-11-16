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
            VStack(spacing: 15) {
                Text("Telemetry is a service that helps app and web developers improve their product by supplying immediate, accurate telemetry data while users use your app. And the best part: It's all anonymized so your users' data stays private!")
                    .padding(.bottom)
                
                NavigationLink("Login to Your Account", destination: LoginView())
                    .buttonStyle(PrimaryButtonStyle())
                NavigationLink("Create a New Organization", destination: RegisterView())
                    .buttonStyle(SecondaryButtonStyle())
                NavigationLink("Join an Organization", destination: JoinOrganizationInfoView())
                    .buttonStyle(SecondaryButtonStyle())
                
                Spacer()
                
                AdaptiveStack(spacing: 15) {
                    Button("Issues on GitHub →") {
                        UIApplication.shared.open(URL(string: "https://github.com/AppTelemetry/Viewer/issues")!)
                    }
                    .buttonStyle(TertiaryButtonStyle())
                    
                    Button("Documentation →") {
                        UIApplication.shared.open(URL(string: "https://apptelemetry.io/pages/docs.html")!)
                    }
                    .buttonStyle(TertiaryButtonStyle())
                    
                    
                    Button("Privacy Policy →") {
                        UIApplication.shared.open(URL(string: "https://apptelemetry.io/pages/privacy-policy.html")!)
                    }
                    .buttonStyle(TertiaryButtonStyle())
                }
                
                Text("Telemetry is currently in public beta! If things don't work the way you expect them to, please be patient, and share your thoughts with Daniel on GitHub or the Slack <3")
                    .font(.footnote)
                    .foregroundColor(.grayColor)
            }
            .padding()
            .navigationTitle("Welcome to Telemetry")
            
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
