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
    
    @State private var isDetailViewShowing: Bool = false
    @State private var isEditViewShowing: Bool = false
    @State private var insightAgeText: String = "Loading..."
    
    let refreshTimer = Timer.publish(
        every: 1, // second
        on: .main,
        in: .common
    ).autoconnect()
    
    var newInsightAgeText: String {
        if let insightData = api.insightData[insight.id] {
            return "Updated \(relativeDateFormatter.localizedString(for: insightData.calculatedAt, relativeTo: Date()))"
        }
        
        else {
            return "Loading..."
        }
    }
    
    let dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
        
    let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
    
    var humanreadableTimeInterval: String {
        let calculatedAt = Date()
        let calculationBeginDate = Date(timeInterval: insight.rollingWindowSize, since: calculatedAt)
        let dateComponents = Calendar.autoupdatingCurrent.dateComponents([.day, .hour, .minute], from: calculationBeginDate, to: calculatedAt)
        return dateComponentsFormatter.string(from: dateComponents) ?? "—"
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                Text(insight.title)
                    .font(.title3)
                
                Spacer()
                Image(systemName: "eye")
                    .foregroundColor(.grayColor)
                    .onTapGesture {
                        isDetailViewShowing = true
                    }
                    .sheet(isPresented: $isDetailViewShowing) {
                        InsightDetailView(isPresented: $isDetailViewShowing, insight: insight, insightGroup: insightGroup, app: app)
                            .environmentObject(api)
                    }
                
                #if os(macOS)
                Image(systemName: "square.and.pencil")
                    .foregroundColor(.grayColor)
                    .onTapGesture {
                        isEditViewShowing = true
                    }
                    .sheet(isPresented: $isEditViewShowing) {
                        CreateOrUpdateInsightForm(app: app, editMode: true, requestBody: InsightDefinitionRequestBody.from(insight: insight), isPresented: $isEditViewShowing, insight: insight, group: insightGroup)
                            .environmentObject(api)
                    }
                #endif
            }
            
            Text("\(insight.subtitle ?? "")\(insight.subtitle != nil ? " • " : "")\(humanreadableTimeInterval) rolling")
                .font(.footnote)
                .padding(.bottom)
                .foregroundColor(.grayColor)
            
            Group {
                if let insightData = api.insightData[insight.id] {
                    switch insightData.displayMode {
                    case .number:
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                InsightNumberView(insightData: insightData)
                                Spacer()
                            }
                            Spacer()
                        }
                    case .pieChart:
                        InsightPieChartView(insightData: insightData)
                    case .lineChart:
                        InsightLineChartView(insightData: insightData)
                    default:
                        VStack {
                            Spacer()
                            
                            HStack {
                                Spacer()
                                Text("\(insightData.displayMode.rawValue.capitalized) is not supported yet in this version.")
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
            
            Spacer()
            
            Group {
                HStack(spacing: 2) {
                    Image(systemName: "arrow.counterclockwise.circle")
                    Text(insightAgeText)
                }
                .font(.footnote)
                .foregroundColor(.grayColor)
                .shadow(color: Color("CardBackgroundColor"), radius: 3, x: 0.0, y: 0.0)
                .onTapGesture {
                    insightAgeText = "Reloading..."
                    api.getInsightData(for: insight, in: insightGroup, in: app)
                    TelemetryManager.shared.send(TelemetrySignal.insightUpdatedManually.rawValue, for: api.user?.email, with: ["insightDisplayMode": insight.displayMode.rawValue])
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
    
    func updateIfNecessary() {
        if let insightData = api.insightData[insight.id] {
            if abs(insightData.calculatedAt.timeIntervalSinceNow) > 60 { // data is over a minute old
                api.getInsightData(for: insight, in: insightGroup, in: app)
                TelemetryManager.shared.send(TelemetrySignal.insightUpdatedAutomatically.rawValue, for: api.user?.email, with: ["insightDisplayMode": insight.displayMode.rawValue])
            }
        } else {
            api.getInsightData(for: insight, in: insightGroup, in: app)
            TelemetryManager.shared.send(TelemetrySignal.insightUpdatedFirstTime.rawValue, for: api.user?.email, with: ["insightDisplayMode": insight.displayMode.rawValue])
        }
        
        insightAgeText = newInsightAgeText
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
