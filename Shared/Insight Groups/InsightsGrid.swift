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
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 800))], alignment: .leading) {
            
            let expandedInsights = insightGroup.insights.filter({ $0.isExpanded }).sorted(by: { $0.order ?? 0 < $1.order ?? 0 })
            let nonExpandedInsights = insightGroup.insights.filter({ !$0.isExpanded }).sorted(by: { $0.order ?? 0 < $1.order ?? 0 })
            
            ForEach(expandedInsights) { insight in
                CardView {
                    InsightView(app: app, insightGroup: insightGroup, insight: insight)
                        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                }
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], alignment: .leading) {
                ForEach(nonExpandedInsights) { insight in
                    CardView {
                        InsightView(app: app, insightGroup: insightGroup, insight: insight)
                            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                    }
                }
            }
        }
        .padding()
    }
}

//struct InsightsGrid_Previews: PreviewProvider {
//    static var previews: some View {
//        InsightsGrid()
//    }
//}
