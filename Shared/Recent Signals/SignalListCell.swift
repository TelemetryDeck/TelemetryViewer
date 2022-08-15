//
//  SignalListCell.swift
//  Telemetry Viewer
//
//  Created by Martin Václavík on 26.12.2021.
//

import DataTransferObjects
import SwiftUI

struct SignalListCell: View {
    let signal: DTOv1.Signal
    let defaultPayloads = ["platform", "systemVersion", "majorSystemVersion", "majorMinorSystemVersion", "appVersion", "buildNumber", "isSimulator", "isDebug", "isTestFlight", "isAppStore", "modelName", "architecture", "operatingSystem", "targetEnvironment", "locale", "telemetryClientVersion"]

    var body: some View {
        AdaptiveStack(horizontalAlignment: .leading) {
            HStack {
                Text(signal.receivedAt, style: .date)
                Text(signal.receivedAt, style: .time)
            }
            .font(.footnote)
            .foregroundColor(.secondary)
            HStack {
                Text(signal.type).bold()
                Text("custom payload")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .if(signal.payload?.filter { !defaultPayloads.contains($0.key) }.isEmpty ?? true) { $0.hidden() }
            }
        }
    }
}

struct SignalListCell_Previews: PreviewProvider {
    static var previews: some View {
        SignalListCell(signal: DTOv1.Signal(appID: UUID(), count: 1, receivedAt: Date(), clientUser: "", sessionID: nil, type: "newSessionBegan", payload: nil, isTestMode: true))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
