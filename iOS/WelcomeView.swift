//
//  WelcomeView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.09.20.
//

import SwiftUI
import TelemetryClient

struct WelcomeView: View {
    @AppStorage("welcomeScreenCohort") var welcomeScreenCohort: String = {
        if Bool.random() {
            return "B"
        } else {
            return "A"
        }
    }()

    var appIconPath: String {
        if welcomeScreenCohort == "B" {
            return "Logo_Sticker"
        }

        return "appIcon"
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                HStack {
                    Spacer()
                    Image(appIconPath)
                        .resizable()
                        .scaledToFit()
                    Spacer()
                }

                NavigationLink("Login to Your Account", destination: LoginView())
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal)
                Button("Register Your Account") {
                    URL(string: "https://dashboard.telemetrydeck.com/registration/organization")!.open()
                }
                .buttonStyle(SecondaryButtonStyle())
                .padding(.horizontal)

                AdaptiveStack(spacing: 15) {
                    NavigationLink("Forgot Password?", destination: PasswordResetView())
                        .buttonStyle(SmallSecondaryButtonStyle())

                    Button("Docs: Getting Started →") {
                        UIApplication.shared.open(URL(string: "https://telemetrydeck.com/pages/docs.html")!)
                    }
                    .buttonStyle(SmallSecondaryButtonStyle())

                    Button("Issues on GitHub →") {
                        UIApplication.shared.open(URL(string: "https://github.com/TelemetryDeck/Viewer/issues")!)
                    }
                    .buttonStyle(SmallSecondaryButtonStyle())
                }
                .padding(.horizontal)

                Text("TelemetryDeck is currently in public beta! If things don't work the way you expect them to, please be patient, and share your thoughts with Daniel on GitHub or the Slack <3")
                    .font(.footnote)
                    .foregroundColor(.grayColor)
            }
            .padding()
            .navigationTitle("Welcome to TelemetryDeck")
        }
        .onAppear {
            TelemetryManager.send("WelcomeViewAppear", with: ["welcomeScreenCohort": welcomeScreenCohort])
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
