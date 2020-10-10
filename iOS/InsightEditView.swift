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
            Text("More Details about this insight will appear here!")
            
            Section {
                Button("Delete this insight") {
                    api.delete(insight: insight, in: insightGroup, in: app)
                    isPresented = false
                }
            }
        }
        .navigationTitle("Edit \(insight.title)")

    }
}

//struct InsightEditView_Previews: PreviewProvider {
//    static var previews: some View {
//        InsightEditView(isPresented: .constant(true), insight: Insight(id: UUID(), title: "TEst Insight", insightType: .count, timeInterval: -36000, configuration: [:], historicalData: nil))
//    }
//}
