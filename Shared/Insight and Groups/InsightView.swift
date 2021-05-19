//
//  InsightView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.09.20.
//

import SwiftUI
import TelemetryClient

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

    var body: some View {
        VStack(alignment: .leading) {
            InsightTitleView(topSelectedInsightID: $topSelectedInsightID, appID: appID, insightGroupID: insightGroupID, insightID: insightID)

            Group {
                if let calculationResult = insightCalculationService.insightData(for: insightID, in: insightGroupID, in: appID), !calculationResult.isEmpty {
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
        if let insightData = insightCalculationService.insightData(for: insightID, in: insightGroupID, in: insightID) {
            switch insightData.displayMode {
            case .raw:
                RawChartView(insightID: insightID, insightGroupID: insightGroupID, appID: appID, topSelectedInsightID: $topSelectedInsightID)
            case .pieChart:
                DonutChartView(insightID: insightID, insightGroupID: insightGroupID, appID: appID, topSelectedInsightID: $topSelectedInsightID)
            case .lineChart:
                LineChartView(insightID: insightID, insightGroupID: insightGroupID, appID: appID, topSelectedInsightID: $topSelectedInsightID)
            case .barChart:
                BarChartView(insightID: insightID, insightGroupID: insightGroupID, appID: appID, topSelectedInsightID: $topSelectedInsightID)
            default:
                VStack {
                    Spacer()

                    HStack {
                        Spacer()
                        Text("\(insightData.displayMode.rawValue.capitalized) is not supported in this version.")
                            .font(.footnote)
                            .foregroundColor(.grayColor)
                            .padding(.vertical)
                        Spacer()
                    }
                    Spacer()
                }
            }
        } else {
            Text("No Data")
        }
    }
}

struct InsightTitleView: View {
    @EnvironmentObject var insightService: InsightService
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
            Text(insightCalculationService.insightData(for: insightID, in: insightGroupID, in: appID)?.title.uppercased() ?? insightService.insight(id: insightID, in: insightGroupID, in: appID)?.title.uppercased() ?? "–")
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

// struct InsightViewOld: View {
//    @EnvironmentObject var api: APIRepresentative
//
//    @Binding var topSelectedInsightID: UUID?
//    private var isSelected: Bool {
//        topSelectedInsightID == insight.id
//    }
//
//    let app: TelemetryApp
//    let insightGroup: DTO.InsightGroup
//    let insight: DTO.InsightDTO
//
//    @State private var isLoading: Bool = false
//    @State private var loadingErrorOccurred: Bool = false
//
//    let refreshTimer = Timer.publish(
//        every: 1, // second
//        on: .main,
//        in: .common
//    ).autoconnect()
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            HStack {
//                Group {
//                    Text(api.insightData[insight.id]?.title.uppercased() ?? insight.title.uppercased())
//                }
//                .font(.footnote)
//                .foregroundColor(isSelected ? .cardBackground : .grayColor)
//                ZStack {
//                    if isLoading {
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle())
//                            .frame(width: 10, height: 10)
//                            .scaleEffect(progressViewScale, anchor: .center)
//                    }
//
//                    Image(systemName: isLoading ? "circle" : "arrow.counterclockwise.circle")
//                        .foregroundColor(isSelected ? .cardBackground : .grayColor)
//                        .onTapGesture {
//                            updateNow()
//                            TelemetryManager.shared.send(TelemetrySignal.insightUpdatedManually.rawValue, for: api.user?.email, with: ["insightDisplayMode": insight.displayMode.rawValue])
//                        }
//                }
//            }
//            .padding(.leading)
//
//            Group {
//                if let insightData = api.insightData[insight.id] {
//                    if insightData.isEmpty {
//                        VStack {
//                            Spacer()
//                            Text("This Insight contains no data. This might be because your app has not sent any signals in the selected time range, or no signals that match this Insight's filters.")
//                                .font(.caption)
//                                .foregroundColor(.grayColor)
//                                .padding(.bottom)
//                                .padding(.horizontal)
//                        }
//                    } else {
//                        switch insightData.displayMode {
//                        case .raw:
//                            RawChartView(insightDataID: insight.id, topSelectedInsightID: $topSelectedInsightID)
//                        case .pieChart:
//                            DonutChartView(insightDataID: insight.id, topSelectedInsightID: $topSelectedInsightID)
//                        case .lineChart:
//                            LineChartView(insightDataID: insight.id, topSelectedInsightID: $topSelectedInsightID)
//                        case .barChart:
//                            BarChartView(insightDataID: insight.id, topSelectedInsightID: $topSelectedInsightID)
//                        default:
//                            VStack {
//                                Spacer()
//
//                                HStack {
//                                    Spacer()
//                                    Text("\(insightData.displayMode.rawValue.capitalized) is not supported in this version.")
//                                        .font(.footnote)
//                                        .foregroundColor(.grayColor)
//                                        .padding(.vertical)
//                                    Spacer()
//                                }
//                                Spacer()
//                            }
//                        }
//                    }
//                } else {
//                    Group {
//                        if loadingErrorOccurred {
//                            VStack(alignment: .leading) {
//                                Image(systemName: "exclamationmark.triangle")
//                                Text("The server was unable to calculate the results in time. Please try again later.")
//                                    .font(.footnote)
//                                    .foregroundColor(.grayColor)
//                            }
//                        } else if isLoading {
//                            VStack {
//                                ProgressView()
//                            }
//                        }
//                    }
//                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
//                }
//            }
//        }
//        .frame(idealHeight: 200)
//        .padding(.top)
//        .onAppear {
//            updateIfNecessary()
//        }
//        .onReceive(refreshTimer) { _ in
//            updateIfNecessary()
//        }
//        .contextMenu {
//            Button("Refresh Now") {
//                updateNow()
//            }
//
//            Divider()
//
//            Button("Delete") {
//                api.delete(insight: insight, in: insightGroup, in: app)
//            }
//        }
//    }
//
//    func updateNow() {
//        isLoading = true
//        loadingErrorOccurred = false
//
//        api.getInsightData(for: insight, in: insightGroup, in: app) { result in
//            isLoading = false
//
//            if (try? result.get()) == nil {
//                loadingErrorOccurred = true
//            }
//        }
//    }
//
//    func updateIfNecessary() {
//        guard !isLoading else { return }
//        guard !loadingErrorOccurred else { return }
//
//        if let insightData = api.insightData[insight.id] {
//            if abs(insightData.calculatedAt.timeIntervalSinceNow) > 60 * 5 { // data is over 5 minutes old
//                updateNow()
//                TelemetryManager.shared.send(TelemetrySignal.insightUpdatedAutomatically.rawValue, for: api.user?.email, with: ["insightDisplayMode": insight.displayMode.rawValue])
//            }
//        } else {
//            updateNow()
//            TelemetryManager.shared.send(TelemetrySignal.insightUpdatedFirstTime.rawValue, for: api.user?.email, with: ["insightDisplayMode": insight.displayMode.rawValue])
//        }
//    }
// }

// struct InsightView_Previews: PreviewProvider {
//    static var platform: PreviewPlatform? = nil
//
//    static var previews: some View {
//        InsightView(
//            app: MockData.app1,
//            insightGroup: InsightGroup(id: UUID(), title: "Test Insight Group"),
//            insight: Insight(id: UUID(), title: "System Version", insightType: .breakdown, timeInterval: -3600*24, configuration: ["breakdown.payloadKey": "systemVersion"], historicalData: [])
//        )
//        .padding()
//        .environmentObject(APIRepresentative())
//        .previewLayout(.fixed(width: 400, height: 200))
//    }
// }
