//
//  QueryService.swift
//  Telemetry Viewer
//
//  Created by Charlotte Böhm on 02.03.22.
//

import DataTransferObjects
import Foundation

class QueryService: ObservableObject {
    private let api: APIClient
    private let errorService: ErrorService

    @Published var timeWindowBeginning: RelativeDateDescription = .goBack(days: 30)
    @Published var timeWindowEnd: RelativeDateDescription = .end(of: .current(.day))
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

    init(api: APIClient, errors: ErrorService) {
        self.api = api
        errorService = errors
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

    func getInsightQuery(ofInsightWithID insightID: DTOv2.Insight.ID) async throws -> CustomQuery {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<CustomQuery, Error>) in
            let url = api.urlForPath(apiVersion: .v3, "insights", insightID.uuidString, "query")

            struct ProduceQueryBody: Codable {
                /// Is Test Mode enabled? (nil means false)
                public var testMode: Bool?
                /// Which time intervals are we looking at?
                public var relativeInterval: RelativeTimeInterval?
                public var interval: QueryTimeInterval?
            }

            let produceQueryBody = ProduceQueryBody(testMode: isTestingMode, interval: .init(beginningDate: timeWindowBeginningDate, endDate: timeWindowEndDate))

            api.post(produceQueryBody, to: url) { (result: Result<CustomQuery, TransferError>) in
                switch result {
                case .success(let query):
                    continuation.resume(returning: query)

                case .failure(let error):
                    self.errorService.handle(transferError: error)
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func createTask(forQuery query: CustomQuery) async throws -> [String: String] {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[String: String], Error>) in

            // If the query has no specified interval, give it the default interval
            var query = query
            if query.relativeIntervals == nil && query.intervals == nil {
                query.intervals = [.init(beginningDate: timeWindowBeginningDate, endDate: timeWindowEndDate)]
            }

            let url = api.urlForPath(apiVersion: .v3, "query", "calculate-async")
            api.post(query, to: url) { (result: Result<[String: String], TransferError>) in
                switch result {
                case .success(let taskID):

                    continuation.resume(returning: taskID)

                case .failure(let error):
                    self.errorService.handle(transferError: error)
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func getTaskResult(forTaskID taskID: String) async throws -> QueryResultWrapper {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<QueryResultWrapper, Error>) in
            let url = api.urlForPath(apiVersion: .v3, "task", taskID, "lastSuccessfulValue")
            api.get(url) { (result: Result<QueryResultWrapper, TransferError>) in
                switch result {
                case .success(let queryResult):

                    continuation.resume(returning: queryResult)

                case .failure(let error):
                    self.errorService.handle(transferError: error)
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func getTaskStatus(forTaskID taskID: String) async throws -> QueryTaskStatus {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<QueryTaskStatus, Error>) in
            let url = api.urlForPath(apiVersion: .v3, "task", taskID, "status")
            api.get(url) { (result: Result<QueryTaskStatusStruct, TransferError>) in
                switch result {
                case .success(let queryStatusStruct):
                    let queryStatus = queryStatusStruct.status
                    continuation.resume(returning: queryStatus)

                case .failure(let error):
                    self.errorService.handle(transferError: error)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
