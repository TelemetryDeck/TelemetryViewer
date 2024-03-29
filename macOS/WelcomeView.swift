//
//  WelcomeView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.09.20.
//

import SwiftUI
import DataTransferObjects

struct WelcomeView: View {
    enum DisplayMode {
        case welcomeView
        case loginView
        case resetPasswordView
    }

    @State private var displayMode: DisplayMode = .welcomeView

    var welcomeView: some View {
        VStack(spacing: 15) {
            Text("TelemetryDeck is a service that helps app and web developers improve their product by " +
                 "supplying immediate, accurate telemetry data while users use your app. And the best part: " +
                 "It's all anonymized so your users' data stays private!")
                .padding(.bottom)

            HStack {
                Spacer()

                Image("appIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(minHeight: 200, maxHeight: 400)
                Spacer()
            }

            Button("Login to Your Account") {
                displayMode = .loginView
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal)

            Button("Register Your Account") {
                URL(string: "https://dashboard.telemetrydeck.com/registration/organization")!.open()
            }
            .buttonStyle(SecondaryButtonStyle())
            .padding(.horizontal)

            AdaptiveStack(spacing: 15) {
                Button("Forgot Password?") {
                    displayMode = .resetPasswordView
                }
                .buttonStyle(SmallSecondaryButtonStyle())

                Button("Docs: Getting Started →") {
                    NSWorkspace.shared.open(URL(string: "https://telemetrydeck.com/pages/docs.html")!)
                }
                .buttonStyle(SmallSecondaryButtonStyle())

                Button("Issues on GitHub →") {
                    NSWorkspace.shared.open(URL(string: "https://github.com/TelemetryDeck/Viewer/issues")!)
                }
                .buttonStyle(SmallSecondaryButtonStyle())
            }
            .padding(.horizontal)

            Text("TelemetryDeck is currently in public beta! If things don't work the way you expect them to, please be patient, " +
                 "and share your thoughts with Daniel on GitHub or the Slack <3")
                .font(.footnote)
                .foregroundColor(.grayColor)
        }
    }

    var body: some View {
        switch self.displayMode {
        case .welcomeView:
            MacNavigationView(title: "Welcome to TelemetryDeck") { welcomeView }
        case .loginView:
            MacNavigationView(title: "Login to Your Account", backButtonAction: { self.displayMode = .welcomeView }, height: 200) { LoginView() }
        case .resetPasswordView:
            MacNavigationView(title: "Password Reset", backButtonAction: { self.displayMode = .welcomeView }, height: 350) { PasswordResetView() }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
