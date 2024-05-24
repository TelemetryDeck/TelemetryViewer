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

    let query: CustomQuery
    let type: ClusterChart.ChartType

    @State var queryResultWrapper: QueryResultWrapper?
    @State var isLoading: Bool = false

    var body: some View {
        VStack {
            if let queryResult = queryResultWrapper?.result {
                ClusterChart(query: query, result: queryResult, type: type)
            }

            if let queryResultWrapper = queryResultWrapper {
                VStack{
                    Text("Calculation took \(queryResultWrapper.calculationDuration) seconds")
                    Text("Last updated \(queryResultWrapper.calculationFinishedAt)")
                }
                .foregroundStyle(.orange)
                .font(.system(size: 10))
                .multilineTextAlignment(.leading)
            }

            if isLoading {
                Text("Loading...")
            }
        }
        .onAppear {
            Task {
                do {
                    try await getQueryResult()
                }
                catch {
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

        //let taskID = try await beginAsyncCalculation()
        let taskID = try await beginAsyncCalcV2()

        try await getLastSuccessfulValue(taskID)

        try await waitUntilTaskStatusIsSuccessful(taskID)

        try await getLastSuccessfulValue(taskID)
    }
}

extension QueryRunner {
    private enum ApiVersion: String {
        case v1
        case v2
        case v3
    }

    private func urlForPath(apiVersion: ApiVersion = .v1, _ path: String..., appendTrailingSlash _: Bool = false) -> URL {
        URL(string: "https://api.telemetrydeck.com/api/" + "\(apiVersion.rawValue)/" + path.joined(separator: "/") + "/")!
    }

    private func authenticatedURLRequest(for url: URL, httpMethod: String, httpBody: Data? = nil, contentType: String = "application/json; charset=utf-8") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(UserTokenDTO(id: UUID(uuidString: "7c736171-9c56-4573-b72f-f9f881c12d7b"), value: "QL41IC283ELWFYXRHC6G22VMTPFK7A3GN1L6INTHPCJGTKA4Y76YZF572P1H2U8OR6HQHUXKWP91M2URKUA49SFCYKQ2XZ8WS0WMR28N2I91OCTDHJMYBAQAIKG2QO73", user: [:]).bearerTokenAuthString, forHTTPHeaderField: "Authorization")

        if let httpBody = httpBody {
            request.httpBody = httpBody
        }

        return request
    }
}

extension QueryRunner {

    // currently inactivate and replaced by V2
    private func beginAsyncCalculation() async throws -> String {
        // create a query task
        let queryBeginURL = urlForPath(apiVersion: .v3, "query", "calculate-async")
        let queryHTTPBody = try JSONEncoder.telemetryEncoder.encode(query)
        var queryBeginRequest = authenticatedURLRequest(for: queryBeginURL, httpMethod: "POST", httpBody: queryHTTPBody)
        queryBeginRequest.httpMethod = "POST"
        let (data, _) = try await URLSession.shared.data(for: queryBeginRequest)
//        print(String(data: data, encoding: .utf8) ?? "")
        guard let taskID = try JSONDecoder.telemetryDecoder.decode([String: String].self, from: data)["queryTaskID"] else {
            throw TransferError.decodeFailed
        }

        return taskID
    }

    private func beginAsyncCalcV2() async throws -> String {
        // create a query task
        let queryBeginURL = api.urlForPath(apiVersion: .v3, "query","calculate-async")
        let queryHTTPBody = try JSONEncoder.telemetryEncoder.encode(query)

        let queryBeginRequest = api.authenticatedURLRequest(for: queryBeginURL, httpMethod: "POST", httpBody: queryHTTPBody)
        let (data, _) = try await URLSession.shared.data(for: queryBeginRequest)
        guard let taskID = try JSONDecoder.telemetryDecoder.decode([String: String].self, from: data)["queryTaskID"] else {
            throw TransferError.decodeFailed
        }

        return taskID
    }

    private func getLastSuccessfulValue(_ taskID: String) async throws {
        // pick up the finished result
        let lastSuccessfulValueURL = urlForPath(apiVersion: .v3, "task", taskID, "lastSuccessfulValue")
        let lastSuccessfulValueURLRequest = authenticatedURLRequest(for: lastSuccessfulValueURL, httpMethod: "GET")
        let (newQueryResultData, response) = try await URLSession.shared.data(for: lastSuccessfulValueURLRequest)
        if (response as? HTTPURLResponse)?.statusCode == 200 {
            queryResultWrapper = try JSONDecoder.telemetryDecoder.decode(QueryResultWrapper.self, from: newQueryResultData)
        }
    }

    private func waitUntilTaskStatusIsSuccessful(_ taskID: String) async throws {
        // wait for the task to finish caluclating
        var taskStatus: QueryTaskStatus = .running
        while taskStatus != .successful {
            let taskStatusURL = urlForPath(apiVersion: .v3, "task", taskID, "status")
//            print(taskStatusURL)
            let taskStatusURLRequest = authenticatedURLRequest(for: taskStatusURL, httpMethod: "GET")
            let (data, _) = try await URLSession.shared.data(for: taskStatusURLRequest)
//            print(String(data: data, encoding: .utf8) ?? "")
            let queryTaskStatus = try JSONDecoder.telemetryDecoder.decode(QueryTaskStatusStruct.self, from: data)
            taskStatus = queryTaskStatus.status
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }

        if taskStatus == .error {
            throw TransferError.serverError(message: "The server returned an error")
        }
    }
}
