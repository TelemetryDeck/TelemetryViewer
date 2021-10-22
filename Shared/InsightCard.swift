//
//  InsightCard.swift
//  InsightCard
//
//  Created by Daniel Jilg on 18.08.21.
//

import SwiftUI
import DataTransferObjects
import SwiftUICharts

struct InsightCard: View {
    @EnvironmentObject var insightService: InsightService
    @EnvironmentObject var insightResultService: InsightResultService
    
    @Binding var selectedInsightID: DTOv2.Insight.ID?
    @Binding var sidebarVisible: Bool
    
    @State var insightWrap: InsightResultWrap?
    @State var loadingState: LoadingState = .idle
    
    private var isSelected: Bool {
        selectedInsightID == insightID
    }
    
    let insightID: DTOv2.Insight.ID
    let isSelectable: Bool
    
    private let refreshTimer = Timer.publish(
        every: 5, // seconds
        on: .main,
        in: .common
    ).autoconnect()
    
    var body: some View {
        Button {
            if isSelectable {
                selectedInsightID = insightID
            
                withAnimation {
                    sidebarVisible = true
                }
            }
        } label: {
            cardContent
        }
        .frame(idealHeight: 200)
        .buttonStyle(CardButtonStyle(isSelected: selectedInsightID == insightID, customAccentColor: Color(hex: insightService.insight(withID: insightID)?.accentColor ?? "")))
    }
    
    var cardContent: some View {
        VStack(alignment: .leading) {
            TinyLoadingStateIndicator(loadingState: insightService.loadingState(for: insightID), title: insightService.insight(withID: insightID)?.title)
                .font(.footnote)
                .foregroundColor(isSelected ? .cardBackground : .grayColor)
                .padding(.leading)
            
            Group {
                if let insightWrap = insightWrap {
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
                    IconOnlyLoadingStateIndicator(loadingState: loadingState)
                }
            }
            .onAppear(perform: retrieve)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .padding(.top)
        .onReceive(refreshTimer) { _ in
            retrieve()
        }
    }
    
    func retrieve() {
        guard selectedInsightID == nil else { return }
        
        if let insight = insightService.insight(withID: insightID) {
            insightResultService.calculate(insight) { loadingState in
                DispatchQueue.main.async {
                    self.loadingState = loadingState
                }
            } onFinish: { wrap in
                DispatchQueue.main.async {
                    self.insightWrap = wrap
                }
            }
        }
    }
}
