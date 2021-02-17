//
//  RootView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.09.20.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var api: APIRepresentative

    var body: some View {
        NavigationView {
            LeftSidebarView()
            AppInfoView()

            #if os(macOS)
            Image("sidebarBackground")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .opacity(0.2)
                .frame(maxWidth: 200)
                .toolbar {
                    Spacer()
                    Text("Sidebar")
                }
            #endif
        }
        .sheet(isPresented: $api.userNotLoggedIn, onDismiss: { api.userNotLoggedIn = api.userToken == nil }) {
            WelcomeView().accentColor(Color("Torange"))
        }
    }
}
