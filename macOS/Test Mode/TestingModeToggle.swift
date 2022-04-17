//
//  TestingModeToggle.swift
//  Telemetry Viewer (macOS)
//
//  Created by Daniel Jilg on 26.10.21.
//

import SwiftUI

struct TestingModeToggle: View {
    @EnvironmentObject var queryService: QueryService
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 0) {
            Text("Test Mode")
                .foregroundColor(Color.secondary)
                .padding(.leading, 8)
                .padding(.vertical, 5.5)
                .onTapGesture {
                    withAnimation {
                        queryService.isTestingMode.toggle()
                    }
                }
            Toggle("Test Mode is \(queryService.isTestingMode ? "ON" : "OFF")", isOn: $queryService.isTestingMode.animation())
                .toggleStyle(.switch)
                .scaleEffect(0.5)
        }
        .background(isHovering ? Color.grayColor.opacity(0.08) : Color.clear)
        .onHover(perform: { hovering in
            isHovering = hovering
        })
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.grayColor.opacity(0.08), lineWidth: 1)
        )
    }
}

struct TestingModeToggle_Previews: PreviewProvider {
    static var previews: some View {
        TestingModeToggle()
    }
}
