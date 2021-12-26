//
//  SignalListCell.swift
//  Telemetry Viewer
//
//  Created by Martin Václavík on 26.12.2021.
//

import SwiftUI
import DataTransferObjects

struct SignalListCell: View {
    let signal: DTOv1.Signal
    
    var body: some View {
        AdaptiveStack(horizontalAlignment: .leading) {
            HStack {
                Text(signal.receivedAt, style: .date)
                Text(signal.receivedAt, style: .time)
            }
            .font(.footnote)
            .foregroundColor(.secondary)
            
            Text(signal.type).bold()
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
