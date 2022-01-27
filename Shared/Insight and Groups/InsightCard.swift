//
//  InsightCard.swift
//  InsightCard
//
//  Created by Daniel Jilg on 18.08.21.
//

import DataTransferObjects
import SwiftUI
import SwiftUICharts
import TelemetryClient

struct InsightCard: View {
    @EnvironmentObject var insightService: InsightService
    @EnvironmentObject var insightResultService: InsightResultService
    
    @Binding var selectedInsightID: DTOv2.Insight.ID?
    @Binding var sidebarVisible: Bool
    
    @State var insightWrap: InsightResultWrap?
    @State var loadingState: LoadingState = .idle
    
    @State var insightCalculationResult: DTOv2.InsightCalculationResult?
    @State var chartDataSet: ChartDataSet?
    @State var error: Error?

    
    private var isSelected: Bool {
        selectedInsightID == insightID
    }
    
    let insightID: DTOv2.Insight.ID
    let isSelectable: Bool
    
    private let refreshTimer = Timer.publish(
        every: 60, // seconds
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
            HStack {
                TinyLoadingStateIndicator(loadingState: insightService.loadingState(for: insightID), title: insightService.insight(withID: insightID)?.title)
                    .font(.footnote)
                    .foregroundColor(isSelected ? .cardBackground : .grayColor)
                    .padding(.leading)
                
                Spacer()
                
                UnobtrusiveIconOnlyLoadingStateIndicator(loadingState: loadingState)
                    .padding(.trailing)
            }
            
            Group {
                if let insightCalculationResult = insightCalculationResult {
                    switch insightCalculationResult.insight.displayMode {
                    case .raw:
                        RawChartView(chartDataSet: chartDataSet!, isSelected: isSelected)
                    case .pieChart:
                        DonutChartView(chartDataset: chartDataSet!, isSelected: isSelected)
                            .padding(.bottom)
                            .padding(.horizontal)
                    case .lineChart:
                        LineChart(chartDataSet: chartDataSet!, isSelected: isSelected)
                    case .barChart:
                        BarChartView(chartDataSet: chartDataSet!, isSelected: isSelected)
                    default:
                        Text("\(insightCalculationResult.insight.displayMode.rawValue.capitalized) is not supported in this version.")
                            .font(.footnote)
                            .foregroundColor(.grayColor)
                            .padding(.vertical)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                    
                } else {
                    LoadingStateIndicator(loadingState: loadingState)
                }
            }
//            .onAppear(perform: retrieve)
            .onAppear(perform: sendTelemetry)
//            .onChange(of: insightResultService.isTestingMode) { _ in retrieve() }
//            .onChange(of: insightResultService.timeWindowBeginning) { _ in retrieve() }
//            .onChange(of: insightResultService.timeWindowEnd) { _ in retrieve() }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .padding(.top)
//        .onReceive(refreshTimer) { _ in
//            retrieve()
//        }
//        .onReceive(insightService.objectWillChange, perform: { retrieve() })
        .task {
            do {
                let result = try await insightResultService.performRetrieval(ofInsightWithID: insightID)
                insightCalculationResult = result
                chartDataSet = ChartDataSet(data: insightCalculationResult!.data, groupBy: insightCalculationResult!.insight.groupBy)
            } catch {
                print(error.localizedDescription)
                self.error = error
            }
        }
        /// I think this might need to be on the list, not the card?
//        .refreshable {
//            do {
//                let result = try await insightResultService.performRetrieval(ofInsightWithID: insightID)
//                insightCalculationResult = result
//                chartDataSet = ChartDataSet(data: insightCalculationResult!.data, groupBy: insightCalculationResult!.insight.groupBy)
//            } catch {
//                print(error.localizedDescription)
//                self.error = error
//            }
//        }
    }
    
    func sendTelemetry() {
        if let displayMode = insightWrap?.calculationResult.insight.displayMode {
            TelemetryManager.send("InsightShown", with: ["insightDisplayMode": displayMode.rawValue])
        }
    }
    
    func retrieve() {
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
