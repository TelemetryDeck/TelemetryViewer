//
//  InsightCard.swift
//  InsightCard
//
//  Created by Daniel Jilg on 18.08.21.
//

import DataTransferObjects
import SwiftUI

import TelemetryClient

struct InsightCard: View {
    @EnvironmentObject var insightService: InsightService
    @EnvironmentObject var queryService: QueryService

    @Binding var selectedInsightID: DTOv2.Insight.ID?
    @Binding var sidebarVisible: Bool

    @State var insightWrap: InsightResultWrap?
    @State var loadingState: LoadingState = .idle

    @State var customQuery: CustomQuery?

    private var isSelected: Bool {
        selectedInsightID == insightID
    }

    let insightID: DTOv2.Insight.ID
    let isSelectable: Bool

    // make this a timer that retrieves insight occasionally?
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
                TinyLoadingStateIndicator(loadingState: insightService.loadingState[insightID] ?? .idle, title: insightService.insight(withID: insightID)?.title)
                    .font(.footnote)
                    .foregroundColor(isSelected ? .cardBackground : .grayColor)
                    .padding(.leading)

                Spacer()

                UnobtrusiveIconOnlyLoadingStateIndicator(loadingState: loadingState)
                    .padding(.trailing)
            }

            Group {
                // This shows an error Sondrine if no internet connection
                if let displaymode = insightService.insightDictionary[insightID]?.displayMode, let query = customQuery {
                    QueryView(viewModel: QueryViewModel(queryService: queryService, customQuery: query, displayMode: displaymode, isSelected: isSelected))
                } else {
                    SondrineLoadingStateIndicator(loadingState: loadingState)
                }
            }

            .onAppear(perform: sendTelemetry)
            .onChange(of: queryService.isTestingMode) { _ in
                customQuery = nil
                Task {
                    await retrieveResults()
                }
            }
            .onChange(of: queryService.timeWindowBeginning) { _ in
                customQuery = nil
                Task {
                    await retrieveResults()
                }
            }
            .onChange(of: queryService.timeWindowEnd) { _ in
                customQuery = nil
                Task {
                    await retrieveResults()
                }
            }
            .onChange(of: insightService.insightDictionary[insightID]) { _ in
                customQuery = nil
                Task {
                    await retrieveResults()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .padding(.top)
        .task {
            await insightService.retrieveInsight(with: insightID)
            await retrieveResults()
        }
    }

    func sendTelemetry() {
        if let displayMode = insightService.insightDictionary[insightID]?.displayMode {
            TelemetryManager.send("InsightShown", with: ["insightDisplayMode": displayMode.rawValue])
        }
    }
    
    @MainActor
    func retrieveResults() async {
        guard loadingState != .loading else { return } // not sufficient
        loadingState = .loading

        do {
            let query = try await queryService.getInsightQuery(ofInsightWithID: insightID)

            customQuery = query

            loadingState = .finished(Date())

        } catch {
            print(error.localizedDescription)

            if let transferError = error as? TransferError {
                loadingState = .error(transferError.localizedDescription, Date())
            } else {
                loadingState = .error(error.localizedDescription, Date())
            }
        }
    }
}
