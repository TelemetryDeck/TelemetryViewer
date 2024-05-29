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

}
