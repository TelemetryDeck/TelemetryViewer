//
//  InsightCard.swift
//  InsightCard
//
//  Created by Daniel Jilg on 18.08.21.
//

import SwiftUI

struct InsightCard: View {
    @EnvironmentObject var insightService: InsightService
    @EnvironmentObject var insightResultService: InsightResultService
    
    @Binding var selectedInsightID: DTOsWithIdentifiers.Insight.ID?
    
    let insightID: DTOsWithIdentifiers.Insight.ID
    
    var body: some View {
        Button {
            selectedInsightID = insightID
            
        } label: {
//            InsightView(topSelectedInsightID: $selectedInsightID, appID: appID, insightGroupID: insightGroup.id, insightID: insight.id)
            VStack {
                LoadingStateIndicator(loadingState: insightService.loadingState(for: insightID), title: insightService.insight(withID: insightID)?.title)
                LoadingStateIndicator(loadingState: insightResultService.loadingState(for: insightID), title: insightResultService.insightCalculationResult(withID: insightID)?.data.count.description)
            }
                
        }
        .buttonStyle(CardButtonStyle(isSelected: selectedInsightID == insightID))
    }
}
