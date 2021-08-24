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
    @Binding var sidebarVisible: Bool
    
    private var isSelected: Bool {
        selectedInsightID == insightID
    }
    
    let insightID: DTOsWithIdentifiers.Insight.ID
    
    private let refreshTimer = Timer.publish(
        every: 5, // seconds
        on: .main,
        in: .common
    ).autoconnect()
    
    var body: some View {
        Button {
            selectedInsightID = insightID
            
            withAnimation {
                sidebarVisible = true
            }
        } label: {
            VStack(alignment: .leading) {
                TinyLoadingStateIndicator(loadingState: insightService.loadingState(for: insightID), title: insightService.insight(withID: insightID)?.title)
                    .font(.footnote)
                    .foregroundColor(isSelected ? .cardBackground : .grayColor)
                    .padding(.leading)
                
                Group {
                    if let insightWrap = insightResultService.insightCalculationResult(withID: insightID) {
                        switch insightWrap.calculationResult.insight.displayMode {
                        case .raw:
                            RawChartView(chartDataSet: insightWrap.chartDataSet, isSelected: isSelected)
                        case .pieChart:
                            DonutChartView(chartDataset: insightWrap.chartDataSet, isSelected: isSelected)
                                .padding(.bottom)
                                .padding(.horizontal)
                        case .lineChart:
                            LineChart(chartDataSet: insightWrap.chartDataSet, isSelected: isSelected)
                        case .barChart:
                            BarChartView(chartDataSet: insightWrap.chartDataSet, isSelected: isSelected)
                        default:
                            Text("\(insightWrap.calculationResult.insight.displayMode.rawValue.capitalized) is not supported in this version.")
                                .font(.footnote)
                                .foregroundColor(.grayColor)
                                .padding(.vertical)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        }
                        
                    } else {
                        IconOnlyLoadingStateIndicator(loadingState: insightResultService.loadingState(for: insightID))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .padding(.top)
        }
        .frame(idealHeight: 200)
        .buttonStyle(CardButtonStyle(isSelected: selectedInsightID == insightID))
        .onReceive(refreshTimer) { _ in _ = insightResultService.insightCalculationResult(withID: insightID) }
    }
}
