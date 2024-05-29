//
//  QueryRunner.swift
//  Telemetry Viewer (iOS)
//
//  Created by Lukas on 23.05.24.
//

import DataTransferObjects
import SwiftUI

struct QueryRunner: View {
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var queryService: QueryService

    let query: CustomQuery
    let type: InsightDisplayMode

    @State var queryResultWrapper: QueryResultWrapper?
    @State var isLoading: Bool = false

    var body: some View {
        VStack(spacing: 10){
            if let queryResult = queryResultWrapper?.result {
                ClusterChart(query: query, result: queryResult, type: type)
                    .padding(.horizontal)
            }

            HStack(spacing: 3){
                Spacer()
                if let queryResultWrapper = queryResultWrapper {
                    Text("Updated")
                    Text(queryResultWrapper.calculationFinishedAt, style: .relative)
                    Text("ago")

                } else {
                    Text("Calculating...")
                }
            }
            .font(.footnote)
            .foregroundStyle(Color.Zinc400)
            .padding(8)
            .background(Color.Zinc50)
        }
        .onAppear {
            Task {
                do {
                    try await getQueryResult()
                } catch {
                    print(error)
                }
            }
        }
        .onChange(of: queryService.isTestingMode) {
            Task {
                do {
                    try await getQueryResult()
                } catch {
                    print(error)
                }
            }
        }
        .onChange(of: queryService.timeWindowBeginning) {
            Task {
                do {
                    try await getQueryResult()
                } catch {
                    print(error)
                }
            }
        }
        .onChange(of: queryService.timeWindowEnd) {
            Task {
                do {
                    try await getQueryResult()
                } catch {
                    print(error)
                }
            }
        }
    }

    private func getQueryResult() async throws {
        isLoading = true
        defer {
            isLoading = false
        }

        let taskID = try await beginAsyncCalcV2()

        try await getLastSuccessfulValue(taskID)

        try await waitUntilTaskStatusIsSuccessful(taskID)

        try await getLastSuccessfulValue(taskID)
    }
}

extension QueryRunner {

    private func beginAsyncCalcV2() async throws -> String {
        // create a query task
        let queryBeginURL = api.urlForPath(apiVersion: .v3, "query", "calculate-async")

        var queryCopy = query

        if queryCopy.intervals == nil && queryCopy.relativeIntervals == nil{
            switch queryService.timeWindowBeginning {
            case .absolute:
                queryCopy.intervals = [.init(beginningDate: queryService.timeWindowBeginningDate, endDate: queryService.timeWindowEndDate)]
            default:
                queryCopy.relativeIntervals = [RelativeTimeInterval(beginningDate: queryService.timeWindowBeginning.toRelativeDate(), endDate: queryService.timeWindowEnd.toRelativeDate())]
            }
        }
        if queryCopy.testMode == nil {
            queryCopy.testMode = queryService.isTestingMode
        }

        let response: [String: String] = try await api.post(data: queryCopy, url: queryBeginURL)
        guard let taskID = response["queryTaskID"] else {
            throw TransferError.decodeFailed
        }

        return taskID
    }

    private func getLastSuccessfulValue(_ taskID: String) async throws {
        // pick up the finished result
        let lastSuccessfulValueURL = api.urlForPath(apiVersion: .v3, "task", taskID, "lastSuccessfulValue")
        queryResultWrapper = try await api.get(url: lastSuccessfulValueURL)
    }

    private func waitUntilTaskStatusIsSuccessful(_ taskID: String) async throws {
        // wait for the task to finish caluclating
        var taskStatus: QueryTaskStatus = .running
        while taskStatus != .successful {
            let taskStatusURL = api.urlForPath(apiVersion: .v3, "task", taskID, "status")

            let queryTaskStatus: QueryTaskStatusStruct = try await api.get(url: taskStatusURL)

            taskStatus = queryTaskStatus.status

            try await Task.sleep(nanoseconds: 1_000_000_000)
        }

        if taskStatus == .error {
            throw TransferError.serverError(message: "The server returned an error")
        }
    }
}

extension RelativeDateDescription {
    func toRelativeDate() -> RelativeDate{
        switch self {
        case .end(let of):
            switch of {
            case .current(let calendarComponent):
                RelativeDate(.end, of: RelativeDate.RelativeDateComponent.from(calenderComponent: calendarComponent), adding: 0)
            case .previous(let calendarComponent):
                RelativeDate(.end, of: RelativeDate.RelativeDateComponent.from(calenderComponent: calendarComponent), adding: -1)
            }
        case .beginning(let of):
            switch of {
            case .current(let calendarComponent):
                RelativeDate(.beginning, of: RelativeDate.RelativeDateComponent.from(calenderComponent: calendarComponent), adding: 0)
            case .previous(let calendarComponent):
                RelativeDate(.beginning, of: RelativeDate.RelativeDateComponent.from(calenderComponent: calendarComponent), adding: -1)
            }
        case .goBack(let days):
            RelativeDate(.beginning, of: .day, adding: -days)
        case .absolute:
            RelativeDate(.beginning, of: .day, adding: -30)
        }
    }
}

extension RelativeDate.RelativeDateComponent {
    static func from (calenderComponent: Calendar.Component) -> Self {
        switch calenderComponent {
        case .hour:
                .hour
        case .day:
                .day
        case .weekOfYear:
                .week
        case .month:
                .month
        case .quarter:
                .quarter
        case .year:
                .year
        default:
                .day
        }
    }
}
