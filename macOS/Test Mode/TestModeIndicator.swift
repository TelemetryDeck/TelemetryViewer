//
//  TestModeIndicator.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 26.10.21.
//

import SwiftUI

struct TestModeIndicator: View {
    @EnvironmentObject var queryService: QueryService

    var body: some View {
        if queryService.isTestingMode {
            StatusMessageContainer(backgroundColor: Color.grayColor.opacity(0.2)) {
                HStack {
                    Text("You are in Test Mode, so you are only seeing signals sent while running development builds in Xcode.")
                        .foregroundColor(Color.secondary)

                    Spacer()

                    Button {
                        URL(string: "https://telemetrydeck.com/pages/test-mode.html")?.open()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Learn More")
                            Image(systemName: "chevron.right")
                        }
                    }
                    #if os(macOS)
                    .buttonStyle(.link)
                    #endif
                    .foregroundColor(Color.secondary)
                }
            }
        }
    }
}

struct TestModeIndicator_Previews: PreviewProvider {
    static var previews: some View {
        TestModeIndicator()
    }
}
