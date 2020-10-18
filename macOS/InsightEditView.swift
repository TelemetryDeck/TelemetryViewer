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
    
    @State private var insightUpdateRequestBody: InsightUpdateRequestBody
    @State private var selectedInsightGroupIndex = 0
    
    private let insight: Insight
    private let insightGroup: InsightGroup
    private let app: TelemetryApp
    
    init(insight: Insight, insightGroup: InsightGroup, app: TelemetryApp, isPresented: Binding<Bool>) {
        self.insight = insight
        self.insightGroup = insightGroup
        self.app = app
        let theInsightUpdateRequestBody = InsightUpdateRequestBody(
            groupID: insight.groupID,
            order: insight.order,
            title: insight.title,
            subtitle: insight.subtitle,
            signalType: insight.signalType,
            uniqueUser: insight.uniqueUser,
            filters: insight.filters,
            rollingWindowSize: insight.rollingWindowSize,
            breakdownKey: insight.breakdownKey,
            displayMode: insight.displayMode)
        self._insightUpdateRequestBody = State(initialValue: theInsightUpdateRequestBody)
        self._isPresented = isPresented
    }
    
    let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter
    }()
    
    var someNumberProxy: Binding<String> {
            Binding<String>(
                get: { (numberFormatter.string(from: NSNumber(value: insightUpdateRequestBody.order ?? 0)) ?? "") },
                set: {
                    if let value = numberFormatter.number(from: $0) {
                        self.insightUpdateRequestBody.order = value.doubleValue
                    }
                }
            )
        }
    
    var body: some View {
        Form {
            Text("Edit \(insight.title)")
                .font(.title2)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
            
            Section {
                HStack {
                    Text("Title")
                    TextField("Title", text: $insightUpdateRequestBody.title)
                }
            }
            
            Section(header: Text("Group")) {
                Picker(selection: $selectedInsightGroupIndex, label: Text("Please choose a group")) {
                    ForEach(0 ..< (api.insightGroups[app]?.count ?? 0)) {
                        Text(api.insightGroups[app]?[$0].title ?? "No Title")
                    }
                }
            }
            
            Section {
                HStack {
                    Text("Order")
                    TextField("Order", text: someNumberProxy)
                }
            }
            
            Button("Delete this insight") {
                api.delete(insight: insight, in: insightGroup, in: app)
                isPresented = false
            }
            
//            Button("Save") {
//                guard let selectedInsightGroup = api.insightGroups[app]?[selectedInsightGroupIndex] else { return }
//                insightUpdateRequestBody.insightGroupID = selectedInsightGroup.id
//                api.update(insight: insight, in: insightGroup, in: app, with: insightUpdateRequestBody)
//                isPresented = false
//            }
//            .keyboardShortcut(.defaultAction)
            
            Button("Close") {
                isPresented = false
            }
            .keyboardShortcut(.cancelAction)
        }
        .onAppear {
//            if let selectedGroup = api.insightGroups[app]?.firstIndex(where: { $0.id == insightUpdateRequestBody.insightGroupID }) {
//                selectedInsightGroupIndex = selectedGroup
//            }
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
