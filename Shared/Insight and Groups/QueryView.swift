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

struct QueryView: View {
    @EnvironmentObject var insightResultService: InsightResultService
    
    @State var loadingState: LoadingState = .idle
    
    let insightID: DTOv2.Insight.ID
    @State var queryResult: QueryResultWrapper? = nil
    
    @State var chartDataset: ChartDataSet? = nil
    
    var body: some View {
        VStack {
            Text("lalal")
            chartDataset.map {
                LineChart(chartDataSet: $0, isSelected: false)
            }
        }
        .task {
            await retrieveResults()
        }
    }
    
    func retrieveResults() async {
        loadingState = .loading
        
        do {
            let query = try await insightResultService.getInsightQuery(ofInsightWithID: insightID) //queryservice
            let taskID = try await insightResultService.createTask(forQuery: query) // viewmodel
            let result = try await insightResultService.getTaskResult(forTaskID: taskID["queryTaskID"]!)
            queryResult = result
            chartDataset = try ChartDataSet(fromQueryResultWrapper: queryResult)
            print(queryResult ?? "oop")
            
            loadingState = .finished(Date())
            
        } catch {
            print(error.localizedDescription)
            
            if let transferError = error as? TransferError {
                loadingState = .error(transferError.localizedDescription, Date())
            } else {
                loadingState = .error(error.localizedDescription, Date())
            }
        }
    }
}

// struct QueryView_Previews: PreviewProvider {
//    static var previews: some View {
//        QueryView()
//    }
// }
