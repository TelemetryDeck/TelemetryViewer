//
//  SignalView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 11.08.20.
//

import SwiftUI

struct SignalView: View {
    var signal: Signal
    
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

                    Group {
                        Text(signal.receivedAt, style: .relative) + Text(" ago")
                    }
                    .font(.footnote)
                    .foregroundColor(.grayColor)

                    Spacer()
                    
                    Text(signal.type).bold()
                }
                
                if showPayload {
                    if let payload = signal.payload {
                        KeyValueView(keysAndValues: payload)
                    } else {
                        Text("No Payload")
                    }
                }
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
