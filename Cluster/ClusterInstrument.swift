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
    let type: InsightDisplayMode

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundStyle(Color.Zinc600)
                .padding(.top)
                .padding(.horizontal)
            QueryRunner(query: query, type: type)
        }
        .compositingGroup()
        .background(.background)
        .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
        .border(Color.Zinc200, width: 1.0)
        .padding(.vertical, 5)
    }
}
