//
//  InsightView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.09.20.
//

import SwiftUI
import TelemetryClient
import DataTransferObjects

struct InsightView: View {
    @EnvironmentObject var insightCalculationService: InsightCalculationService

    /// In the outside world, the insight ID that is selected by the user, if any
    @Binding var topSelectedInsightID: UUID?

    let appID: UUID
    let insightGroupID: UUID
    let insightID: UUID

    private var isSelected: Bool {
        topSelectedInsightID == insightID
    }
    
    private let refreshTimer = Timer.publish(
        every: 5, // seconds
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {
        VStack(alignment: .leading) {
            InsightTitleView(topSelectedInsightID: $topSelectedInsightID, appID: appID, insightGroupID: insightGroupID, insightID: insightID)

            Group {
                if let calculationResult = insightCalculationService.calculationResult(for: insightID, in: insightGroupID, in: appID), !calculationResult.insightData.data.isEmpty {
                    InsightDisplayView(topSelectedInsightID: $topSelectedInsightID, appID: appID, insightGroupID: insightGroupID, insightID: insightID)
                } else {
                    if insightCalculationService.isInsightCalculating(id: insightID) {
                        ProgressView()
                    } else {
                        InsightEmptyView()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(idealHeight: 200)
        .padding(.top)
        // Request a refresh every now and then
        .onReceive(refreshTimer) { _ in _ = insightCalculationService.calculationResult(for: insightID, in: insightGroupID, in: appID) }
    }
}

struct InsightDisplayView: View {
    @EnvironmentObject var insightCalculationService: InsightCalculationService

    /// In the outside world, the insight ID that is selected by the user, if any
    @Binding var topSelectedInsightID: UUID?

    let appID: UUID
    let insightGroupID: UUID
    let insightID: UUID

    private var isSelected: Bool {
        topSelectedInsightID == insightID
    }

    var body: some View {
        if let insightData = insightCalculationService.calculationResult(for: insightID, in: insightGroupID, in: insightID) {
            switch insightData.insightData.displayMode {
            case .raw:
                ServiceRawChartView(insightID: insightID, insightGroupID: insightGroupID, appID: appID, topSelectedInsightID: $topSelectedInsightID)
            case .pieChart:
                ServiceDonutChartView(insightID: insightID, insightGroupID: insightGroupID, appID: appID, topSelectedInsightID: $topSelectedInsightID)
            case .lineChart:
                LineChartView(insightID: insightID, insightGroupID: insightGroupID, appID: appID, topSelectedInsightID: $topSelectedInsightID)
            case .barChart:
                ServiceBarChartView(insightID: insightID, insightGroupID: insightGroupID, appID: appID, topSelectedInsightID: $topSelectedInsightID)
            default:
                Text("\(insightData.insightData.displayMode.rawValue.capitalized) is not supported in this version.")
                    .font(.footnote)
                    .foregroundColor(.grayColor)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        } else {
            Text("No Data")
        }
    }
}

struct InsightTitleView: View {
    @EnvironmentObject var insightService: OldInsightService
    @EnvironmentObject var insightCalculationService: InsightCalculationService

    /// In the outside world, the insight ID that is selected by the user, if any
    @Binding var topSelectedInsightID: UUID?

    let appID: UUID
    let insightGroupID: UUID
    let insightID: UUID

    private var isSelected: Bool {
        topSelectedInsightID == insightID
    }

    var body: some View {
        HStack {
            Text(insightCalculationService.calculationResult(for: insightID, in: insightGroupID, in: appID)?.insightData.title.uppercased() ?? insightService.insight(id: insightID, in: insightGroupID, in: appID)?.title.uppercased() ?? "–")
                .font(.footnote)
                .foregroundColor(isSelected ? .cardBackground : .grayColor)
            InsightReloadButtonView(isSelected: isSelected, insightID: insightID, insightGroupID: insightGroupID, appID: appID)
            Spacer()
        }
        .padding(.leading)
    }
}

struct InsightEmptyView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("This Insight contains no data. This might be because your app has not sent any signals in the selected time range, or no signals that match this Insight's filters.")
                .font(.caption)
                .foregroundColor(.grayColor)
                .padding(.bottom)
                .padding(.horizontal)
        }
    }
}
