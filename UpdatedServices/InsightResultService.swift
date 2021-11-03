//
//  InsightService.swift
//  InsightService
//
//  Created by Daniel Jilg on 17.08.21.
//

import Combine
import Foundation
import DataTransferObjects
import SwiftUICharts
import TelemetryDeckClient

final class InsightRetrievalOperation: AsyncOperation {
    private let cache: CacheLayer
    private let cacheKey: String
    private let targetURL: URL
    private let api: APIClient
    private let onFinish: (InsightResultWrap) -> ()
    private let onStatusChange: (LoadingState) -> ()
    private let insightResultService: InsightResultService
    private let insightID: DTOv2.Insight.ID

    init(apiClient: APIClient, insightID: DTOv2.Insight.ID, targetURL: URL, cache: CacheLayer, cacheKey: String, resultService: InsightResultService, onStatusChange: @escaping (LoadingState) -> (), onFinish: @escaping (InsightResultWrap) -> ()) {
        api = apiClient
        self.targetURL = targetURL
        self.onFinish = onFinish
        self.onStatusChange = onStatusChange
        self.cacheKey = cacheKey
        self.cache = cache
        self.insightResultService = resultService
        self.insightID = insightID
    }

    override func main() {
        // If the result is already cached, return the cached result
        if let insightCalculationResult = cache.insightCalculationResultCache[cacheKey],
           !cache.insightCalculationResultCache.needsUpdate(forKey: cacheKey)
        {
            onFinish(insightCalculationResult)
            finish()
            return
        }
        
        insightResultService.loadingState[insightID] = .loading
        onStatusChange(.loading)
        
        // Otherwise, retrieve the result from the API
        api.get(targetURL) { (result: Result<DTOv2.InsightCalculationResult, TransferError>) in
            
            switch result {
            case .success(let insightCalculationResult):
                let chartDataSet = ChartDataSet(data: insightCalculationResult.data, groupBy: insightCalculationResult.insight.groupBy)
                let resultWrap = InsightResultWrap(chartDataSet: chartDataSet, calculationResult: insightCalculationResult)
                self.cache.insightCalculationResultCache[self.cacheKey] = resultWrap
                self.onStatusChange(.finished(Date()))
                self.insightResultService.loadingState[self.insightID] = .finished(Date())
                self.onFinish(resultWrap)
                
            case .failure(let transferError):
                self.insightResultService.loadingState[self.insightID] = .error(transferError.localizedDescription, Date())
                self.onStatusChange(.error(transferError.localizedDescription, Date()))
            }
            
            self.finish()
        }
    }

    override func cancel() {
        // urlTask?.cancel()
        super.cancel()
    }
}

class InsightResultService: ObservableObject {
    private let api: APIClient
    private let cache: CacheLayer
    private let errorService: ErrorService
    
    lazy var insightResultRetrievalQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Insight Result Retrieval queue"
        queue.maxConcurrentOperationCount = 3
        return queue
    }()
    
    fileprivate let loadingState = Cache<DTOv2.Insight.ID, LoadingState>()
    
    var loadingCancellable: AnyCancellable?
    var cacheCancellable: AnyCancellable?
    
    @Published var timeWindowBeginning: RelativeDateDescription = .beginning(of: .current(.month))
    @Published var timeWindowEnd: RelativeDateDescription = .end(of: .current(.month))
    @Published var isTestingMode: Bool = UserDefaults.standard.bool(forKey: "isTestingMode") {
        didSet {
            UserDefaults.standard.set(isTestingMode, forKey: "isTestingMode")
        }
    }
    
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
    
    func loadingState(for insightID: DTOv2.Insight.ID) -> LoadingState {
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
    
    func cacheKey(insight: DTOv2.Insight) -> String {
        let uuidString = insight.id.uuidString
        let earlierDateString = Formatter.iso8601.string(from: timeWindowBeginningDate)
        let laterDateString = Formatter.iso8601.string(from: timeWindowEndDate.startOfHour)
        let insightHash = insight.hashValue
        return "\(uuidString)/\(earlierDateString)/\(laterDateString)/\(isTestingMode ? "testingMode" : "liveMode")/\(insightHash)/v1"
    }
    
    func calculate(_ insight: DTOv2.Insight, onStatusChange: @escaping (LoadingState) -> (), onFinish: @escaping (InsightResultWrap) -> ()) {
        // If the result is already cached, return the cached result
        let cacheKey = cacheKey(insight: insight)
        if let insightCalculationResult = cache.insightCalculationResultCache[cacheKey], !cache.insightCalculationResultCache.needsUpdate(forKey: cacheKey) {
            onFinish(insightCalculationResult)
            return
        }
        
        let url = api.urlForPath(apiVersion: .v2, "insights", insight.id.uuidString, "result",
                                 Formatter.iso8601noFS.string(from: timeWindowBeginningDate),
                                 Formatter.iso8601noFS.string(from: timeWindowEndDate),
                                 "\(isTestingMode ? "true" : "live")"
        )
        
        let op = InsightRetrievalOperation(apiClient: api, insightID: insight.id, targetURL: url, cache: cache, cacheKey: cacheKey, resultService: self, onStatusChange: onStatusChange, onFinish: onFinish)
        
        // Set the newest operation to the highest priority, LIFO style
        op.queuePriority = .high
        insightResultRetrievalQueue.operations.forEach { o in
            o.queuePriority = .normal
        }
        
        insightResultRetrievalQueue.addOperation(op)
    }
    
    func insightCalculationResult(withID insightID: DTOv2.Insight.ID) -> InsightResultWrap? {
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
    
    func retrieveInsightCalculationResult(with insightID: DTOv2.Insight.ID) {
        cache.queue.async { [weak self] in
            self?.performRetrieval(ofInsightWithID: insightID)
        }
    }
}

private extension InsightResultService {
    func performRetrieval(ofInsightWithID insightID: DTOv2.Insight.ID) {
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
        
        api.get(url) { [weak self] (result: Result<DTOv2.InsightCalculationResult, TransferError>) in
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
