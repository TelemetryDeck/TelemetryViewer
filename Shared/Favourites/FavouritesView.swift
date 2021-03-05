//
//  FavouritesView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.03.21.
//

import SwiftUI

struct FavouritesView: View {
    var body: some View {
        VStack {
            Text("Welcome to Telemetry")
                .font(.title)
                .foregroundColor(.grayColor)
                .onAppear {
                    #if os(macOS)
                        setupSidebars()
                    #else
                        print("hi")
                    #endif
                }

            Text("This is where your favourites appear.")
                .foregroundColor(.grayColor)
        }
    }
}

struct FavouritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavouritesView()
    }
}
