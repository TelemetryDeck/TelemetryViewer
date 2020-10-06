//
//  InsightView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.09.20.
//

import SwiftUI

struct InsightView: View {
    
    @EnvironmentObject var api: APIRepresentative
    let app: TelemetryApp
    let insightGroup: InsightGroup
    let insight: Insight
    
    @State var insightAgeText: String = "Loading..."
    
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
        let calculationBeginDate = Date(timeInterval: insight.timeInterval, since: calculatedAt)
        let dateComponents = Calendar.autoupdatingCurrent.dateComponents([.day, .hour, .minute], from: calculationBeginDate, to: calculatedAt)
        return dateComponentsFormatter.string(from: dateComponents) ?? "—"
    }
    
    var body: some View {
        #if os (macOS)
        let grayColor = Color(NSColor.systemGray)
        #else
        let grayColor = Color(UIColor.systemGray)
        #endif
        
        VStack(alignment: .leading) {
            Text(insight.title).font(.title3)
            Text("\(insight.insightType.humanReadableName) of signals less than \(humanreadableTimeInterval) old")
                .font(.footnote)
                .foregroundColor(grayColor)
            
            
            if let insightData = api.insightData[insight.id] {
                    switch insightData.insightType {
                    case .breakdown:
                        InsightBreakdownView(insightData: insightData)
                    case .count:
                        InsightCountView(insightData: insightData, insightHistoricalData: api.insightHistoricalData[insight.id] ?? [])
                    default:
                        Text("This Insight Type is not supported yet in this version.")
                    }
            }
            
            else {
                Text("Oh yes we are still Loading and it is taking some time so here's a secret: This data was crunched by elves!").redacted(reason: .placeholder)
            }
            
            Spacer()

            HStack(spacing: 2) {
                Image(systemName: "arrow.counterclockwise.circle")
                Text(insightAgeText)
            }
            .font(.footnote)
            .foregroundColor(grayColor)
            .shadow(color: Color("CardBackgroundColor"), radius: 3, x: 0.0, y: 0.0)
            .shadow(color: Color("CardBackgroundColor"), radius: 1, x: 0.0, y: 0.0)
            .shadow(color: Color("CardBackgroundColor"), radius: 5, x: 0.0, y: 0.0)
            .onTapGesture {
                insightAgeText = "Reloading..."
                api.getInsightData(for: insight, in: insightGroup, in: app)
                api.getInsightHistoricalData(for: insight, in: insightGroup, in: app)
                TelemetryManager().send(.insightUpdatedManually, for: api.user?.email)
            }
        }
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
            if abs(insightData.calculatedAt.timeIntervalSinceNow) > 60*5 { // data is over 5 minutes old
                api.getInsightData(for: insight, in: insightGroup, in: app)
                TelemetryManager().send(.insightUpdatedAutomatically, for: api.user?.email)
            }
        } else {
            api.getInsightData(for: insight, in: insightGroup, in: app)
        }
        
        if let insightHistoricalData = api.insightHistoricalData[insight.id] {
            if let lastEntry = insightHistoricalData.sorted(by: { $0.calculatedAt < $1.calculatedAt }).last, abs(lastEntry.calculatedAt.timeIntervalSinceNow) > 3600*24 { // There should be a new historical entry available
                api.getInsightHistoricalData(for: insight, in: insightGroup, in: app)
            }
        } else {
            api.getInsightHistoricalData(for: insight, in: insightGroup, in: app)
        }
        
        insightAgeText = newInsightAgeText
    }
}

struct InsightView_Previews: PreviewProvider {
    static var platform: PreviewPlatform? = nil
    
    static var previews: some View {
        InsightView(
            app: MockData.app1,
            insightGroup: InsightGroup(id: UUID(), title: "Test Insight Group"),
            insight: Insight(id: UUID(), title: "System Version", insightType: .breakdown, timeInterval: -3600*24, configuration: ["breakdown.payloadKey": "systemVersion"], historicalData: [])
        )
        .padding()
        .environmentObject(APIRepresentative())
        .previewLayout(.fixed(width: 400, height: 200))
    }
}
