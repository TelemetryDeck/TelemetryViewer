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
    
    @State private var showPayload: Bool = false
    
    var columns = [
        GridItem(.fixed(50)),
        GridItem(.fixed(150)),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var payloadColumns = [GridItem(.flexible())]
    
    var body: some View {
        
        ListItemView {
            VStack {
                HStack(alignment: .top) {
                    Image(systemName: "arrowtriangle.right.fill")
                        .imageScale(.large)
                        .rotationEffect(.init(degrees: showPayload ? 90 : 0))
                        .foregroundColor(.accentColor)
                    
                    Text(dateFormatter.string(from: signal.receivedAt))
                        .frame(width: 150)
                    
                    Text(signal.type).bold()
                    
                    Spacer()
                    
                    Text(signal.clientUser.prefix(16))
                        .foregroundColor(.grayColor)
                }
                
                if showPayload {
                    if let payload = signal.payload {
                        KeyValueView(keysAndValues: payload)
                    } else {
                        Text("No Payload")
                    }
                }
                
                
                #if os(macOS)
                Rectangle()
                    .foregroundColor(.grayColor)
                    .frame(maxHeight: 1)
                    .padding()
                #endif
            }
        }
        .animation(.easeOut)
        .onTapGesture {
            showPayload.toggle()
        }
        
    }
}

struct SignalView_Previews: PreviewProvider {
    static var previews: some View {
        let signal: Signal = .init(
            id: UUID(),
            receivedAt: Date(),
            clientUser: UUID().uuidString,
            type: "ExampleSignal",
            payload: [
                "appVersion": "1.0",
                "systemVersion": "14.0"
            ]
        )
        SignalView(signal: signal)
    }
}
