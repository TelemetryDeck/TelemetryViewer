//
//  InsightService.swift
//  InsightService
//
//  Created by Daniel Jilg on 17.08.21.
//

import Combine
import Foundation

class InsightResultService: ObservableObject {
    private let api: APIClient
    private let cache: CacheLayer
    private let errorService: ErrorService
    
    private let loadingState = Cache<DTOsWithIdentifiers.Insight.ID, LoadingState>()
    
    var loadingCancellable: AnyCancellable?
    var cacheCancellable: AnyCancellable?
    
    @Published var timeWindowBeginning: RelativeDateDescription = .beginning(of: .previous(.month))
    @Published var timeWindowEnd: RelativeDateDescription = .end(of: .current(.month))
    
    var timeWindowBeginningDate: Date { resolvedDate(from: timeWindowBeginning, defaultDate: Date() - 30 * 24 * 3600) }
    var timeWindowEndDate: Date { resolvedDate(from: timeWindowEnd, defaultDate: Date()) }

    func setTimeIntervalTo(days: Int) {
        timeWindowEnd = .end(of: .current(.day))
        timeWindowBeginning = .goBack(days: days)
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    var timeIntervalDescription: String {
        return "\(dateFormatter.string(from: timeWindowBeginningDate)) – \(dateFormatter.string(from: timeWindowEndDate))"
    }
    
    func resolvedDate(from date: RelativeDateDescription, defaultDate: Date) -> Date {
        let currentDate = Date()

        switch date {
        case .end(of: let of):
            switch of {
            case .current(let calendarComponent):
                return currentDate.end(of: calendarComponent) ?? defaultDate
            case .previous(let calendarComponent):
                return currentDate.beginning(of: calendarComponent)?.adding(calendarComponent, value: -1).end(of: calendarComponent) ?? defaultDate
            }

        case .beginning(of: let of):
            switch of {
            case .current(let calendarComponent):
                return currentDate.beginning(of: calendarComponent) ?? defaultDate
            case .previous(let calendarComponent):
                return currentDate.beginning(of: calendarComponent)?.adding(calendarComponent, value: -1).beginning(of: calendarComponent) ?? defaultDate
            }

        case .goBack(days: let days):
            return currentDate.adding(.day, value: -days).beginning(of: .day) ?? defaultDate

        case .absolute(date: let date):
            return date
        }
    }
    
    init(api: APIClient, cache: CacheLayer, errors: ErrorService) {
        self.api = api
        self.cache = cache
        errorService = errors
        
        loadingCancellable = loadingState.objectWillChange.receive(on: DispatchQueue.main).sink { [weak self] in self?.objectWillChange.send() }
        cacheCancellable = cache.insightCalculationResultCache.objectWillChange.receive(on: DispatchQueue.main).sink { [weak self] in self?.objectWillChange.send() }
    }
    
    func loadingState(for insightID: DTOsWithIdentifiers.Insight.ID) -> LoadingState {
        let loadingState = loadingState[insightID] ?? .idle
        
        // after 60 seconds, clear the error, allowing another load
        switch loadingState {
        case .error(_, let date):
            if date < Date() - 60 {
                self.loadingState[insightID] = .idle
                return .idle
            }
        default:
            break
        }
        
        return loadingState
    }
    
    func cacheKey(insight: DTOsWithIdentifiers.Insight) -> String {
        let uuidString = insight.id.uuidString
        let earlierDateString = Formatter.iso8601.string(from: timeWindowBeginningDate)
        let laterDateString = Formatter.iso8601.string(from: timeWindowEndDate.startOfHour)
        let insightHash = insight.hashValue
        return "\(uuidString)/\(earlierDateString)/\(laterDateString)/\(insightHash)/v1"
    }
    
    func insightCalculationResult(withID insightID: DTOsWithIdentifiers.Insight.ID) -> InsightResultWrap? {
        guard let insight = cache.insightCache[insightID],
              let insightCalculationResult = cache.insightCalculationResultCache[cacheKey(insight: insight)]
        else {
            retrieveInsightCalculationResult(with: insightID)
            return nil
        }
        
        if cache.insightCalculationResultCache.needsUpdate(forKey: cacheKey(insight: insight)) {
            retrieveInsightCalculationResult(with: insightID)
        }
        
        return insightCalculationResult
    }
    
    func retrieveInsightCalculationResult(with insightID: DTOsWithIdentifiers.Insight.ID) {
        cache.queue.async { [weak self] in
            self?.performRetrieval(ofInsightWithID: insightID)
        }
    }
}

private extension InsightResultService {
    func performRetrieval(ofInsightWithID insightID: DTOsWithIdentifiers.Insight.ID) {
        switch loadingState(for: insightID) {
        case .loading, .error:
            return
        default:
            break
        }

        loadingState[insightID] = .loading
        
        let url = api.urlForPath(apiVersion: .v2, "insights", insightID.uuidString, "result",
                                 Formatter.iso8601noFS.string(from: timeWindowBeginningDate),
                                 Formatter.iso8601noFS.string(from: timeWindowEndDate))
        
        api.get(url) { [weak self] (result: Result<DTOsWithIdentifiers.InsightCalculationResult, TransferError>) in
            self?.cache.queue.async { [weak self] in
                switch result {
                case .success(let insightCalculationResult):
                    let chartDataSet = ChartDataSet(data: insightCalculationResult.data, groupBy: insightCalculationResult.insight.groupBy)
                    
                    if let insight = self?.cache.insightCache[insightID], let cacheKey = self?.cacheKey(insight: insight) {
                        self?.cache.insightCalculationResultCache[cacheKey] = InsightResultWrap(chartDataSet: chartDataSet, calculationResult: insightCalculationResult)
                    }
                    
                    self?.loadingState[insightID] = .finished(Date())
                case .failure(let error):
                    self?.errorService.handle(transferError: error)
                    self?.loadingState[insightID] = .error(error.localizedDescription, Date())
                }
            }
        }
    }
}
