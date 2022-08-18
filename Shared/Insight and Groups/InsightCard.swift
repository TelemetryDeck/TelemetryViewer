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

    /// ok, for some reason I broke some things, and I don't understand it?
    /// like, the app seems to not know which insights are selected anymore?
    /// also, some results are not retrieved ever for some reason?
    /// Decode Failed:  dataCorrupted(Swift.DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid JSON.", underlyingError: Optional(Error Domain=NSCocoaErrorDomain Code=3840 "Unable to parse empty data." UserInfo={NSDebugDescription=Unable to parse empty data.})))
    /// weird error? the respone was nil? I should handle that somehow? probably lol
    ///
    /// also I should totally fix the applist, it makes a million api requests lol
    ///
    /// oh, maybe due to no dispatch main!

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
                // currently, if there is no internet connection, there will be no error sondrine, because the display mode and query are empty. this is not good. maybe there should be always something given to the queryview, so that it can handle showing the loading/error state, or the loading state needs to be shown in this view here, and both views use the same loading state, or this views loading state is given to the query view? or something like it?
                if let displaymode = insightService.insightDictionary[insightID]?.displayMode, let query = customQuery {
                    QueryView(viewModel: QueryViewModel(queryService: queryService, customQuery: query, displayMode: displaymode, isSelected: isSelected))
                } else {
                    SondrineLoadingStateIndicator(loadingState: loadingState)
                }

//                QueryView(viewModel: QueryViewModel(queryService: queryService, customQuery: customQuery, displayMode: insightService.insightDictionary[insightID]?.displayMode, isSelected: isSelected))
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
                /// wait. if the insight is first loaded, this makes us load the query two times, right? so we do not need to load the query on load and on change?
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .padding(.top)
//        .onReceive(refreshTimer) { _ in
//            retrieve()
//        }
//        .onReceive(insightService.objectWillChange, perform: { retrieve() })
        .task {
//            insightService.insightDictionary[insightID] = nil
            await insightService.retrieveInsight(with: insightID)
            await retrieveResults()
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
        if let displayMode = insightService.insightDictionary[insightID]?.displayMode {
            TelemetryManager.send("InsightShown", with: ["insightDisplayMode": displayMode.rawValue])
        }
    }

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
