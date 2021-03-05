//
//  FavouritesView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.03.21.
//

import SwiftUI

struct FavouritesView: View {
    var body: some View {
        Text("Welcome to Telemetry")
            .font(.title)
            .foregroundColor(.grayColor)
            .onAppear {
                #if os(macOS)
                    setupSidebars()
                #endif
            }
    }
}

struct FavouritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavouritesView()
    }
}
