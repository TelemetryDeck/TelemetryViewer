//
//  SignalView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 11.08.20.
//

import SwiftUI

struct SignalView: View {
    var signal: Signal
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        Label {
            VStack(alignment: .leading) {
                HStack(spacing: 3) {
                    Text(signal.type).bold()
                    Text("received at")
                    Text(signal.receivedAt)
                }
                
                HStack(spacing: 2) {
                    Text("from user")
                    Text(signal.clientUser).bold()
                }
                
                Text(signal.payload?.debugDescription ?? "No Payload").foregroundColor(.gray)
            }
        } icon: {
            Image(systemName: "waveform")
        }
        
        
    }
}

struct SignalView_Previews: PreviewProvider {
    static var previews: some View {
        let signal: Signal = .init(id: UUID(), receivedAt: "Date()", clientUser: "randomClientUser", type: "ExampleSignal", payload: nil)
        SignalView(signal: signal)
    }
}
