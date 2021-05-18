//
//  InsightDetailView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 10.10.20.
//

import SwiftUI

struct InsightDetailView: View {
    @EnvironmentObject var api: APIRepresentative

    @Binding var isPresented: Bool
    let insight: DTO.InsightCalculationResult
    let insightGroup: DTO.InsightGroup
    let app: TelemetryApp

    private var encoder: JSONEncoder {
        let encoder = JSONEncoder.telemetryEncoder
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }

    var body: some View {
        let closeButton = Button("Close") {
            isPresented = false
        }
        .keyboardShortcut(.cancelAction)

        Form {
            Text("\(insight.title)")
                .font(.title2)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))

            Text("More Details about this insight will appear here.")

            Text(String(data: try! encoder.encode(insight), encoding: .utf8) ?? "An error occurred")
                .font(.system(.body, design: .monospaced))

            closeButton
        }
        .padding()
    }
}

//
// struct InsightDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        InsightDetailView(isPresented: .constant(true), insight: Insight(id: UUID(), title: "Test Insight", insightType: .count, timeInterval: -36000, configuration: [:], historicalData: nil))
//    }
// }
