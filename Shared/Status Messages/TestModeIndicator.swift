//
//  TestModeIndicator.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 26.10.21.
//

import SwiftUI

struct TestModeIndicator: View {
    @EnvironmentObject var insightResultService: InsightResultService

    var body: some View {
        if insightResultService.isTestingMode {
            StatusMessageContainer(backgroundColor:  Color("GiantGoldfish")) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("You are in Testing Mode, so you are only seeing signals sent while running development builds in XCode.").font(.headline)
                        Text("Switch to Live Mode to see signals sent from your actual users instead of test data.")
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        Button {
                            URL(string: "https://telemetrydeck.com/pages/testing-mode.html")?.open()
                        } label: {
                            HStack(spacing: 0) {
                            Text("Learn More")
                                Image(systemName: "chevron.right")
                            }
                        }
                        .buttonStyle(.link)
                        .foregroundColor(Color.secondary)

                        Button("Switch to Live Mode") {
                            withAnimation {
                                insightResultService.isTestingMode = false
                            }
                        }
                    }
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
