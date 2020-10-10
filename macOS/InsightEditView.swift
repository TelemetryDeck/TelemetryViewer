//
//  InsightEditView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 10.10.20.
//

import SwiftUI

struct InsightEditView: View {
    @EnvironmentObject var api: APIRepresentative
    
    @Binding var isPresented: Bool
    let insight: Insight
    let insightGroup: InsightGroup
    let app: TelemetryApp
    
    var body: some View {
        Form {
            Text("Edit \(insight.title)")
                .font(.title2)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
            
            Text("More Details about this insight will appear here.")
            
            Button("Delete this insight") {
                api.delete(insight: insight, in: insightGroup, in: app)
                isPresented = false
            }
            
            Button("Close") {
                isPresented = false
            }
            .keyboardShortcut(.cancelAction)
        }
        .padding()

    }
}
//
//struct InsightEditView_Previews: PreviewProvider {
//    static var previews: some View {
//        InsightEditView(isPresented: .constant(true), insight: Insight(id: UUID(), title: "TEst Insight", insightType: .count, timeInterval: -36000, configuration: [:], historicalData: nil))
//    }
//}
