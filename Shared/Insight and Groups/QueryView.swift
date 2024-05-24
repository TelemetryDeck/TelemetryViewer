//
//  QueryView.swift
//  Telemetry Viewer
//
//  Created by Charlotte Böhm on 22.02.22.
//

import DataTransferObjects
import SwiftUI
import Charts

// @State var customQuery: CustomQuery

@MainActor
class QueryViewModel: ObservableObject {
    let queryService: QueryService
    let customQuery: CustomQuery
    let displayMode: InsightDisplayMode
    let isSelected: Bool

    public let runningTimer = Timer.publish(
        every: 0.5, // seconds
        on: .main,
        in: .common
    ).autoconnect()

    public let successTimer = Timer.publish(
        every: 60, // seconds
        on: .main,
        in: .common
    ).autoconnect()

    init(queryService: QueryService, customQuery: CustomQuery, displayMode: InsightDisplayMode, isSelected: Bool) {
        self.queryService = queryService
        self.customQuery = customQuery
        self.displayMode = displayMode
        self.isSelected = isSelected
    }

    @Published var loadingState: LoadingState = .loading
    @Published var queryTaskStatus: QueryTaskStatus = .running

    var taskID: [String: String] = ["queryTaskID": ""]
    @Published var queryResult: QueryResultWrapper?
    @Published var chartDataSet: ChartDataSet?

    // func that posts the query on load and loads the last result

    func retrieveResults() async {
        loadingState = .loading

        do {
            taskID = try await queryService.createTask(forQuery: customQuery)
            let queryTaskID = taskID["queryTaskID"]
            let result = try await queryService.getTaskResult(forTaskID: queryTaskID!)
            if result.result != nil {
                let chartDataSet = try ChartDataSet(fromQueryResultWrapper: result)
                DispatchQueue.main.async {
                    self.queryResult = result
                    self.chartDataSet = chartDataSet
                    self.loadingState = .finished(Date())
                }
            }

        } catch {
            print(error.localizedDescription)

            DispatchQueue.main.async {
                if let transferError = error as? TransferError {
                    switch transferError {
                    case .transferFailed, .decodeFailed:
                        self.loadingState = .error(transferError.localizedDescription, Date())
                    case .serverError(let message):
                        if message == "Not Found" {
                            self.loadingState = .loading
                        } else {
                            self.loadingState = .error(transferError.localizedDescription, Date())
                        }
                    }
                } else if let chartDataSetError = error as? ChartDataSetError {
                    self.loadingState = .error(chartDataSetError.localizedDescription, Date())
                } else {
                    self.loadingState = .error(error.localizedDescription, Date())
                }
            }
        }
    }

    /// Asks for the status every 0.5 seconds if current status is running and loads the result if status is successful
    @MainActor
    func checkIfStillRunning() async {
        switch loadingState {
        case .idle, .loading, .finished:
            break
        case .error:
            return
        }

        if queryTaskStatus == .running {
            loadingState = .loading

            do {
                let queryTaskID = taskID["queryTaskID"]
                let taskStatus = try await queryService.getTaskStatus(forTaskID: queryTaskID!)

                switch taskStatus {
                case .successful:
                    DispatchQueue.main.async {
                        self.queryTaskStatus = taskStatus
                    }
                    let queryTaskID = taskID["queryTaskID"]
                    let result = try await queryService.getTaskResult(forTaskID: queryTaskID!)
                    let chartDataSet = try ChartDataSet(fromQueryResultWrapper: result)
                    DispatchQueue.main.async {
                        self.queryResult = result
                        self.chartDataSet = chartDataSet
                        self.loadingState = .finished(Date())
                    }
                case .error:
                    DispatchQueue.main.async {
                        self.loadingState = .error("string", Date())
                        self.queryTaskStatus = taskStatus
                    }

                case .running:
                    DispatchQueue.main.async {
                        self.loadingState = .finished(Date())
                        self.queryTaskStatus = taskStatus
                    }
                }
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    if let transferError = error as? TransferError {
                        switch transferError {
                        case .transferFailed, .decodeFailed:
                            self.loadingState = .error(transferError.localizedDescription, Date())
                        case .serverError(let message):
                            if message == "Not Found" {
                                self.loadingState = .loading
                            } else {
                                self.loadingState = .error(transferError.localizedDescription, Date())
                            }
                        }
                    } else if let chartDataSetError = error as? ChartDataSetError {
                        self.loadingState = .error(chartDataSetError.localizedDescription, Date())
                    } else {
                        self.loadingState = .error(error.localizedDescription, Date())
                    }
                }
            }
        }
    }

    /// Ask for the status every 10 seconds
    func checkStatus() async {
        switch loadingState {
        case .idle, .loading, .finished:
            break
        case .error:
            return
        }

        if queryTaskStatus == .successful {
            loadingState = .loading
            do {
                let queryTaskID = taskID["queryTaskID"]
                let taskStatus = try await queryService.getTaskStatus(forTaskID: queryTaskID!)
                switch taskStatus {
                case .successful:
                    DispatchQueue.main.async {
                        self.loadingState = .finished(Date())
                        self.queryTaskStatus = taskStatus
                    }
                case .error:
                    DispatchQueue.main.async {
                        self.loadingState = .error("string", Date())
                        self.queryTaskStatus = taskStatus
                    }

                case .running:
                    DispatchQueue.main.async {
                        self.loadingState = .finished(Date())
                        self.queryTaskStatus = taskStatus
                    }
                }
            } catch {
                print(error.localizedDescription)

                DispatchQueue.main.async {
                    if let transferError = error as? TransferError {
                        switch transferError {
                        case .transferFailed, .decodeFailed:
                            self.loadingState = .error(transferError.localizedDescription, Date())
                        case .serverError(let message):
                            if message == "Not Found" {
                                self.loadingState = .loading
                            } else {
                                self.loadingState = .error(transferError.localizedDescription, Date())
                            }
                        }
                    } else if let chartDataSetError = error as? ChartDataSetError {
                        self.loadingState = .error(chartDataSetError.localizedDescription, Date())
                    } else {
                        self.loadingState = .error(error.localizedDescription, Date())
                    }
                }
            }
        }
    }
}

struct QueryView: View {
    @StateObject var viewModel: QueryViewModel

    var body: some View {
        VStack {
//            Text("asdf")
//            viewModel.chartDataSet.map {
//                LineChart(chartDataSet: $0, isSelected: false)
//            }
            if let chartDataSet = viewModel.chartDataSet {
                switch viewModel.displayMode {
                case .raw:
                    RawChartView(chartDataSet: chartDataSet, isSelected: viewModel.isSelected)
                case .pieChart:
                    DonutChartView(chartDataset: chartDataSet, isSelected: viewModel.isSelected)
                        .padding(.bottom)
                        .padding(.horizontal)
                case .lineChart:
                    LineChart(chartDataSet: chartDataSet, isSelected: viewModel.isSelected)
                case .barChart:
                    BarChartView(chartDataSet: chartDataSet, isSelected: viewModel.isSelected)
                default:
                    Text("\(viewModel.displayMode.rawValue.capitalized) is not supported in this version.")
                        .font(.footnote)
                        .foregroundColor(.grayColor)
                        .padding(.vertical)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            } else {
                SondrineLoadingStateIndicator(loadingState: viewModel.loadingState)
                    .onTapGesture {
                        Task {
                            await viewModel.retrieveResults()
                        }
                    }
            }
        }
        .task {
            await viewModel.retrieveResults()
        }
        .onReceive(viewModel.runningTimer) { _ in
            Task {
                await viewModel.checkIfStillRunning()
            }
        }
        .onReceive(viewModel.successTimer) { _ in
            Task {
                await viewModel.checkStatus()
            }
        }
    }
}

struct QueryViewV2: View {
    @StateObject var viewModel: QueryViewModel

    //let displayMode: String

    var body: some View {
        VStack {
            if let queryResult = viewModel.queryResult?.result, let chartDataSet = viewModel.chartDataSet{
                switch viewModel.displayMode {
                case .raw:
                    RawChartView(chartDataSet: chartDataSet, isSelected: viewModel.isSelected)
                case .pieChart:
                    DonutChartView(chartDataset: chartDataSet, isSelected: viewModel.isSelected)
                        .padding(.bottom)
                        .padding(.horizontal)
                case .lineChart:
                    ClusterLineChart(query: viewModel.customQuery, result: queryResult)
                case .barChart:
                    ClusterBarChart(query: viewModel.customQuery, result: queryResult)
                default:
                    Text("\(viewModel.displayMode.rawValue.capitalized) is not supported in this version.")
                        .font(.footnote)
                        .foregroundColor(.grayColor)
                        .padding(.vertical)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            } else {
                SondrineLoadingStateIndicator(loadingState: viewModel.loadingState)
                    .onTapGesture {
                        Task {
                            await viewModel.retrieveResults()
                        }
                    }
            }

            /*if let chartDataSet = viewModel.chartDataSet {
                switch viewModel.displayMode {
                case .raw:
                    RawChartView(chartDataSet: chartDataSet, isSelected: viewModel.isSelected)
                case .pieChart:
                    DonutChartView(chartDataset: chartDataSet, isSelected: viewModel.isSelected)
                        .padding(.bottom)
                        .padding(.horizontal)
                case .lineChart:
                    LineChart(chartDataSet: chartDataSet, isSelected: viewModel.isSelected)
                case .barChart:
                    BarChartView(chartDataSet: chartDataSet, isSelected: viewModel.isSelected)
                default:
                    Text("\(viewModel.displayMode.rawValue.capitalized) is not supported in this version.")
                        .font(.footnote)
                        .foregroundColor(.grayColor)
                        .padding(.vertical)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            } else {
                SondrineLoadingStateIndicator(loadingState: viewModel.loadingState)
                    .onTapGesture {
                        Task {
                            await viewModel.retrieveResults()
                        }
                    }
            }*/
        }
        .task {
            await viewModel.retrieveResults()
        }
        .onReceive(viewModel.runningTimer) { _ in
            Task {
                await viewModel.checkIfStillRunning()
            }
        }
        .onReceive(viewModel.successTimer) { _ in
            Task {
                await viewModel.checkStatus()
            }
        }
    }
}

// struct QueryView_Previews: PreviewProvider {
//    static var previews: some View {
//        QueryView()
//    }
// }
