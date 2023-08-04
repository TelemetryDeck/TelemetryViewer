//
//  ClusterInstrument.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.08.23.
//

import SwiftUI
import DataTransferObjects


struct ClusterInstrument: View {
    let query: CustomQuery
    let title: String
    let type: ClusterChart.ChartType
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title)
                .padding(.bottom)
            QueryRunner(query: query, type: type)
        }
        .padding()
    }
}
