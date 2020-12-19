//
//  InsightView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.09.20.
//

import SwiftUI
import TelemetryClient

struct InsightView: View {
    @EnvironmentObject var api: APIRepresentative
    
    let app: TelemetryApp
    let insightGroup: InsightGroup
    let insight: Insight

    @State private var isLoading: Bool = false
    @State private var loadingErrorOccurred: Bool = false
    
    let refreshTimer = Timer.publish(
        every: 1, // second
        on: .main,
        in: .common
    ).autoconnect()
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                Text(insight.title.uppercased())
                    .font(.footnote)
                    .foregroundColor(.grayColor)
                Image(systemName: isLoading ? "arrow.up.arrow.down.circle" : "arrow.counterclockwise.circle")
                    .foregroundColor(.grayColor)
                    .onTapGesture {
                        updateNow()
                        TelemetryManager.shared.send(TelemetrySignal.insightUpdatedManually.rawValue, for: api.user?.email, with: ["insightDisplayMode": insight.displayMode.rawValue])
                    }
                
                if loadingErrorOccurred {
                    Text("Server Error".uppercased())
                        .foregroundColor(Color("Torange"))
                }
                
                Spacer()
                
                Image(systemName: "square.and.pencil")
                    .foregroundColor(.grayColor)
            }
            
            Group {
                if let insightData = api.insightData[insight.id] {
                    switch insightData.displayMode {
                    case .raw:
                        RawChartView(insightDataID: insight.id)
                    case .pieChart:
                        DonutChartView(insightDataID: insight.id)
                    case .lineChart:
                        LineChartView(insightDataID: insight.id)
                    case .barChart:
                        BarChartView(insightDataID: insight.id)
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
                }
                
                else {
                    Text("Oh yes we are still Loading and it is taking some time so here's a secret: This data was crunched by elves!").redacted(reason: .placeholder)
                }
            }
        }
        .frame(idealHeight: 200)
        .padding()
        .onAppear() {
            updateIfNecessary()
        }
        .onReceive(refreshTimer) { _ in
            updateIfNecessary()
        }
    }
    
    func updateNow() {
        isLoading = true
        loadingErrorOccurred = false
        api.getInsightData(for: insight, in: insightGroup, in: app) { result in
            isLoading = false
            
            if ((try? result.get()) == nil) {
                loadingErrorOccurred = true
            }
        }
    }
    
    func updateIfNecessary() {
        if let insightData = api.insightData[insight.id] {
            if abs(insightData.calculatedAt.timeIntervalSinceNow) > 60 * 5 { // data is over 5 minutes old
                updateNow()
                TelemetryManager.shared.send(TelemetrySignal.insightUpdatedAutomatically.rawValue, for: api.user?.email, with: ["insightDisplayMode": insight.displayMode.rawValue])
            }
        } else {
            updateNow()
            TelemetryManager.shared.send(TelemetrySignal.insightUpdatedFirstTime.rawValue, for: api.user?.email, with: ["insightDisplayMode": insight.displayMode.rawValue])
        }
    }
}

//struct InsightView_Previews: PreviewProvider {
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
//}
