//
//  ClusterInstrument.swift
//  Telemetry Viewer (iOS)
//
//  Created by Lukas on 23.05.24.
//

import SwiftUI
import DataTransferObjects


struct ClusterInstrument: View {
    @EnvironmentObject var api: APIClient

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
