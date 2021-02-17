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
                HStack {
                    Spacer()
                    Image("appIcon")
                        .resizable()
                        .scaledToFit()
                    Spacer()
                }

                NavigationLink("Login to Your Account", destination: LoginView())
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal)
                NavigationLink("Create a New Organization", destination: RegisterView())
                    .buttonStyle(SecondaryButtonStyle())
                    .padding(.horizontal)
                NavigationLink("Join an Organization", destination: JoinOrganizationView())
                    .buttonStyle(SecondaryButtonStyle())
                    .padding(.horizontal)

                AdaptiveStack(spacing: 15) {
                    Button("Docs: Getting Started →") {
                        UIApplication.shared.open(URL(string: "https://apptelemetry.io/pages/docs.html")!)
                    }
                    .buttonStyle(SmallSecondaryButtonStyle())

                    Button("Privacy Policy →") {
                        UIApplication.shared.open(URL(string: "https://apptelemetry.io/pages/privacy-policy.html")!)
                    }
                    .buttonStyle(SmallSecondaryButtonStyle())

                    Button("Issues on GitHub →") {
                        UIApplication.shared.open(URL(string: "https://github.com/AppTelemetry/Viewer/issues")!)
                    }
                    .buttonStyle(SmallSecondaryButtonStyle())
                }
                .padding(.horizontal)

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
