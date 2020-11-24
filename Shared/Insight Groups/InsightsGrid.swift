//
//  InsightsGrid.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 02.11.20.
//

import SwiftUI

struct InsightsGrid: View {
    let app: TelemetryApp
    let insightGroup: InsightGroup

    @State private var selectedItem: Insight?
    @State private var sidebarShown: Bool = false
    
    var body: some View {
        HStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 800))], alignment: .leading) {
                    let expandedInsights = insightGroup.insights.filter({ $0.isExpanded }).sorted(by: { $0.order ?? 0 < $1.order ?? 0 })
                    let nonExpandedInsights = insightGroup.insights.filter({ !$0.isExpanded }).sorted(by: { $0.order ?? 0 < $1.order ?? 0 })

                    ForEach(expandedInsights) { insight in
                        CardView(selected: selectedItem?.id == insight.id && sidebarShown) {
                            InsightView(app: app, insightGroup: insightGroup, insight: insight)
                        }
                        .onTapGesture {
                            selectedItem = insight
                            withAnimation {
                                sidebarShown = true
                            }
                        }
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], alignment: .leading) {
                        ForEach(nonExpandedInsights) { insight in
                            CardView(selected: selectedItem?.id == insight.id && sidebarShown) {
                                InsightView(app: app, insightGroup: insightGroup, insight: insight)
                            }
                            .onTapGesture {
                                selectedItem = insight
                                withAnimation {
                                    sidebarShown = true
                                }
                            }
                        }
                    }
                }
            }

            if sidebarShown {
                DetailSidebar(isOpen: $sidebarShown, maxWidth: 600) {
                    CreateOrUpdateInsightForm(app: app, editMode: true, requestBody: InsightDefinitionRequestBody.from(insight: selectedItem!), insight: selectedItem!, group: insightGroup)
                }.transition(.move(edge: .trailing))
            }
        }
        .navigationTitle("\(insightGroup.title)")
        .padding()
    }
}

//struct InsightsGrid_Previews: PreviewProvider {
//    static var previews: some View {
//        InsightsGrid()
//    }
//}
