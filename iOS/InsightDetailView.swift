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
    let insight: Insight
    let insightGroup: InsightGroup
    let app: TelemetryApp
    
    var body: some View {
        let closeButton = Button("Close") {
            isPresented = false
        }
        .keyboardShortcut(.cancelAction)

        

        NavigationView {
            Form {
                Text("Moreeee Details about this insight will appear here.")
                
                Text(String(data: try! JSONEncoder.telemetryEncoder.encode(insight), encoding: .utf8) ?? "An error occurred")
                    .font(.system(.body, design: .monospaced))

                NavigationLink(
                    destination: CreateOrUpdateInsightForm(app: app, editMode: true, requestBody: InsightDefinitionRequestBody.from(insight: insight), isPresented: $isPresented, insight: insight, group: insightGroup).environmentObject(api),
                    label: {
                        Label("Edit", systemImage: "square.and.pencil")
                    }
                )
            }
                .navigationTitle(insight.title)
                .navigationBarItems(leading: closeButton)
        }
    }
}

//struct InsightDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        InsightDetailView(isPresented: .constant(true), insight: Insight(id: UUID(), title: "Test Insight", insightType: .count, timeInterval: -36000, configuration: [:], historicalData: nil))
//    }
//}
