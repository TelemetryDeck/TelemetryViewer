//
//  BottomPooper.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 24.09.21.
//

import SwiftUI

struct BottomPooper: View {    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.cardBackground.opacity(0.5))

            Image("sidebarBackground")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 44, alignment: .center)
        }
    }
}
