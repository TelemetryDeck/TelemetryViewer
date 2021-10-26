//
//  TestingModeToggle.swift
//  Telemetry Viewer (macOS)
//
//  Created by Daniel Jilg on 26.10.21.
//

import SwiftUI

struct TestingModeToggle: View {
    @EnvironmentObject var insightResultService: InsightResultService
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 0) {
            Text("Testing")
                .foregroundColor(Color.secondary)
                .padding(.leading, 8)
                .onTapGesture {
                    withAnimation {
                        insightResultService.isTestingMode.toggle()
                    }
                }
            Toggle("Testing Mode is \(insightResultService.isTestingMode ? "ON" : "OFF")", isOn: $insightResultService.isTestingMode.animation())
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
