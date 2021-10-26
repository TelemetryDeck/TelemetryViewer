//
//  StatusMessage.swift
//  StatusMessage
//
//  Created by Daniel Jilg on 17.09.21.
//

import DataTransferObjects
import SwiftUI

struct StatusMessage: View {
    let statusMessage: DTOv2.StatusMessage
    
    var body: some View {
        StatusMessageContainer(backgroundColor: .telemetryOrange.opacity(0.3)) {
            HStack(alignment: .top) {
                Image(systemName: statusMessage.systemImageName ?? "info.circle")
                    .font(.system(size: 18))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 10)
                    .foregroundColor(Color.secondary)
                
                VStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        Text(statusMessage.validFrom, style: .date)
                    
                        statusMessage.validUntil.map {
                            Text(" – ") + Text($0, style: .date)
                        }
                    }
                    .font(.footnote)
                    .foregroundColor(Color.secondary)
                    
                    Text(statusMessage.title)
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                
                    statusMessage.description.map {
                        Text($0)
                            .foregroundColor(Color.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    #if os(macOS)
                    if statusMessage.id == "restricted-mode-notification" {
                        Button("Open Settings") {
                            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                        }
                    }
                    #endif
                }
                
                Spacer()
            }
        }
    }
}
