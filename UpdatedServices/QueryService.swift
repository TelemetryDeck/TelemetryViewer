//
//  QueryService.swift
//  Telemetry Viewer
//
//  Created by Charlotte Böhm on 02.03.22.
//

import DataTransferObjects
import Foundation
import SwiftUICharts

class QueryService: ObservableObject {
    private let api: APIClient
    private let errorService: ErrorService

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
            let url = api.urlForPath(apiVersion: .v3, "insights", insightID.uuidString, "query",
                                     Formatter.iso8601noFS.string(from: timeWindowBeginningDate),
                                     Formatter.iso8601noFS.string(from: timeWindowEndDate),
                                     "\(isTestingMode ? "true" : "live")")
            api.get(url) { (result: Result<CustomQuery, TransferError>) in
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
            api.get(url) { (result: Result<QueryTaskStatus, TransferError>) in
                switch result {
                case .success(let queryStatus):

                    continuation.resume(returning: queryStatus)

                case .failure(let error):
                    self.errorService.handle(transferError: error)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

