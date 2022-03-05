//
//  QueryView.swift
//  Telemetry Viewer
//
//  Created by Charlotte Böhm on 22.02.22.
//

import DataTransferObjects
import SwiftUI
import SwiftUICharts

// @State var customQuery: CustomQuery

class QueryViewModel: ObservableObject {
    let queryService: QueryService
    let insightID: DTOv2.Insight.ID
    
    public let runningTimer = Timer.publish(
        every: 0.5, // seconds
        on: .main,
        in: .common
    ).autoconnect()
    
    public let successTimer = Timer.publish(
        every: 10, // seconds
        on: .main,
        in: .common
    ).autoconnect()
    
    init(queryService: QueryService, insightID: DTOv2.Insight.ID) {
        self.queryService = queryService
        self.insightID = insightID
    }
    
    @Published var loadingState: LoadingState = .idle
    @Published var queryTaskStatus: QueryTaskStatus = .running
    
    var customQuery: CustomQuery?
    var taskID: [String: String] = ["queryTaskID": ""]
    @Published var queryResult: QueryResultWrapper? = nil
    @Published var chartDataset: ChartDataSet? = nil
     
    // func that posts the query on load and loads the last result
    
    func retrieveResults() async {
        loadingState = .loading
        
        do {
            customQuery = try await queryService.getInsightQuery(ofInsightWithID: insightID) // this belongs in the insight view
            if customQuery != nil {
                taskID = try await queryService.createTask(forQuery: customQuery!)
                let result = try await queryService.getTaskResult(forTaskID: taskID["queryTaskID"]!)
                if result.result != nil {
                    queryResult = result
                    chartDataset = try ChartDataSet(fromQueryResultWrapper: queryResult)
                    loadingState = .finished(Date())
                }
            }
            
        } catch {
            print(error.localizedDescription)
            
            if let transferError = error as? TransferError {
                loadingState = .error(transferError.localizedDescription, Date())
            } else if let chartDataSetError = error as? ChartDataSetError {
                loadingState = .error(chartDataSetError.localizedDescription, Date())
            } else {
                loadingState = .error(error.localizedDescription, Date())
            }
        }
    }
    
    // func that asks for the status every 0.5 seconds if current status is running and loads the result if status is successful
    
    func checkIfStillRunning() async {
        if queryTaskStatus == .running {
            loadingState = .loading
        
            do {
                queryTaskStatus = try await queryService.getTaskStatus(forTaskID: taskID["queryTaskID"]!)
                if queryTaskStatus == .successful {
                    let result = try await queryService.getTaskResult(forTaskID: taskID["queryTaskID"]!)
                    queryResult = result
                    chartDataset = try ChartDataSet(fromQueryResultWrapper: queryResult)
                    print(queryResult ?? "oop")
            
                    loadingState = .finished(Date())
                } else if queryTaskStatus == .error {
                    loadingState = .error("Query Task Status error.", Date())
                } else {
                    loadingState = .finished(Date())
                }
            
            } catch {
                print(error.localizedDescription)
            
                if let transferError = error as? TransferError {
                    loadingState = .error(transferError.localizedDescription, Date())
                } else if let chartDataSetError = error as? ChartDataSetError {
                    loadingState = .error(chartDataSetError.localizedDescription, Date())
                } else {
                    loadingState = .error(error.localizedDescription, Date())
                }
            }
        }
    }
    
    // func that asks for the status every 10 seconds
    
    func checkStatus() async {
        if queryTaskStatus == .successful {
            loadingState = .loading
            do {
                queryTaskStatus = try await queryService.getTaskStatus(forTaskID: taskID["queryTaskID"]!)
                if queryTaskStatus == .successful {
                    loadingState = .finished(Date())
                } else if queryTaskStatus == .error {
                    loadingState = .error("Query Task Status error.", Date())
                } else {
                    loadingState = .finished(Date())
                }
            
            } catch {
                print(error.localizedDescription)
            
                if let transferError = error as? TransferError {
                    loadingState = .error(transferError.localizedDescription, Date())
                } else if let chartDataSetError = error as? ChartDataSetError {
                    loadingState = .error(chartDataSetError.localizedDescription, Date())
                } else {
                    loadingState = .error(error.localizedDescription, Date())
                }
            }
        }
    }
}

struct QueryView: View {
    @StateObject var viewModel: QueryViewModel
    
    var body: some View {
        VStack {
            Text("lalal")
            viewModel.chartDataset.map {
                LineChart(chartDataSet: $0, isSelected: false)
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

// struct QueryView_Previews: PreviewProvider {
//    static var previews: some View {
//        QueryView()
//    }
// }
