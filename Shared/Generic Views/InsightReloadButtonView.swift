//
//  LoadingCircleView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 19.05.21.
//

import SwiftUI

struct InsightReloadButtonView: View {
    @EnvironmentObject var insightCalculationService: InsightCalculationService
    let isSelected: Bool
    let insightID: UUID
    let insightGroupID: UUID
    let appID: UUID
    
    private var isLoading: Bool { insightCalculationService.isInsightCalculating(id: insightID) }
    
    private var isLoadingError: Bool { insightCalculationService.isInsightCalculationFailed(id: insightID) }
    
    
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: isSelected ? .cardBackground : .grayColor))
                    .frame(width: 10, height: 10)
                    .scaleEffect(progressViewScale, anchor: .center)
            }

            Image(systemName: isLoadingError ? "exclamationmark.triangle" : (isLoading ? "circle" : "arrow.counterclockwise.circle"))
                .foregroundColor(isSelected ? .cardBackground : .grayColor)
                .onTapGesture {
                    insightCalculationService.getInsightData(for: insightID, in: insightGroupID, in: appID)
                }
        }
    }
}

struct LoadingCircleView_Previews: PreviewProvider {
    static var previews: some View {
        InsightReloadButtonView(isSelected: false, insightID: UUID(), insightGroupID: UUID(), appID: UUID())
    }
}
