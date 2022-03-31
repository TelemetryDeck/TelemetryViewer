//
//  InsightService.swift
//  InsightService
//
//  Created by Daniel Jilg on 17.08.21.
//

import Combine
import DataTransferObjects
import Foundation

class InsightService: ObservableObject {
    private let api: APIClient
    private let errorService: ErrorService
    
    @Published var loadingState = [DTOv2.Insight.ID: LoadingState]()

    /// I think this is what I want, probably? like, a published object that can be updated from anywhere, basically a local observable object cache
    @Published var insightDictionary = [DTOv2.Insight.ID: DTOv2.Insight]()
    
    init(api: APIClient, errors: ErrorService) {
        self.api = api
        errorService = errors
    }
    
    func insight(withID insightID: DTOv2.Insight.ID) -> DTOv2.Insight? {
        return insightDictionary[insightID]
    }

    func retrieveInsight(with insightID: DTOv2.Insight.ID) {
        Task {
            await retrieveInsight(with: insightID)
        }
    }
    
    func retrieveInsight(with insightID: DTOv2.Insight.ID) async {
        DispatchQueue.main.async {
            self.loadingState[insightID] = .loading
        }
        do {
            let insight = try await getInsight(withID: insightID)
            DispatchQueue.main.async {
                self.insightDictionary[insightID] = insight
                        
                self.loadingState[insightID] = .finished(Date())
            }
                    
        } catch {
            print(error.localizedDescription)
            DispatchQueue.main.async {
                if let transferError = error as? TransferError {
                    self.loadingState[insightID] = .error(transferError.localizedDescription, Date())
                } else {
                    self.loadingState[insightID] = .error(error.localizedDescription, Date())
                }
            }
        }
    }
    
    func create(insightWith: DTOv2.Insight, callback: ((Result<String, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath(apiVersion: .v2, "insights")
        
        api.post(insightWith, to: url, defaultValue: nil) { (result: Result<String, TransferError>) in
            callback?(result)
        }
    }
    
    func update(insightID: UUID, in insightGroupID: UUID, in appID: UUID, with insightDTO: DTOv2.Insight, callback: ((Result<DTOv2.Insight, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath(apiVersion: .v2, "insights", insightID.uuidString)

        api.patch(insightDTO, to: url) { [unowned self] (result: Result<DTOv2.Insight, TransferError>) in
            retrieveInsight(with: insightID)
            
            callback?(result)
        }
    }

    func delete(insightID: UUID, callback: ((Result<String, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath(apiVersion: .v2, "insights", insightID.uuidString)
        
        api.delete(url) { (result: Result<String, TransferError>) in
            callback?(result)
        }
    }
    
    /// Gets a list of all Insight IDs of Insights that have been marked as widgetable
    ///
    /// Since an HTTP request is involved, this method is asynchronous. Provide a callback that will be called
    /// once the data has been returned from the server.
    ///
    /// Should the server return an error, or should a communication error occur, this method will call
    /// the callback black with an empty array and inform the APIClient error service about the error.
    func widgetableInsights(callback: @escaping (([DTOv2.AppWithInsights]) -> Void)) {
        let url = api.urlForPath(apiVersion: .v2, "insights", "widgetableInsights")
        
        api.get(url) { (result: Result<[DTOv2.AppWithInsights], TransferError>) in
            switch result {
            case let .success(appWithInsightList):
                callback(appWithInsightList)
            case let .failure(transferError):
                callback([])
                self.api.handleError(transferError)
            }
        }
    }

    // should this function automatically update the insight dictionary? probably better to do it here, right? but also I think it might not work to update it in an async func? no, it should work with DispatchQueue.main.async. hmm. I think for error handling it might be more convenient to do it like I'm doing it right now
    func getInsight(withID insightID: DTOv2.Insight.ID) async throws -> DTOv2.Insight {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<DTOv2.Insight, Error>) in
            let url = api.urlForPath(apiVersion: .v2, "insights", insightID.uuidString)
            api.get(url) { (result: Result<DTOv2.Insight, TransferError>) in
                switch result {
                case let .success(insight):

                    continuation.resume(returning: insight)

                case let .failure(error):
                    self.errorService.handle(transferError: error)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
