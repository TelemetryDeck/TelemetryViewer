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

    @Binding var sidebarElement: SidebarElement?

    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 800))], alignment: .leading) {
                let expandedInsights = insightGroup.insights.filter({ $0.isExpanded }).sorted(by: { $0.order ?? 0 < $1.order ?? 0 })
                let nonExpandedInsights = insightGroup.insights.filter({ !$0.isExpanded }).sorted(by: { $0.order ?? 0 < $1.order ?? 0 })

                ForEach(expandedInsights) { insight in
                    CardView(selected: sidebarElement == SidebarElement.insight(id: insight.id)) {
                        InsightView(app: app, insightGroup: insightGroup, insight: insight)
                    }
                    .onTapGesture {
                        sidebarElement = .insight(id: insight.id)
                    }
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], alignment: .leading) {
                    ForEach(nonExpandedInsights) { insight in

                        CardView(selected: sidebarElement == SidebarElement.insight(id: insight.id)) {
                            InsightView(app: app, insightGroup: insightGroup, insight: insight)
                        }
                        .onTapGesture {
                            sidebarElement = .insight(id: insight.id)
                        }
                    }

                }
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
