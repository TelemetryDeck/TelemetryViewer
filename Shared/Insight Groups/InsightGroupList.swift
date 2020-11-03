//
//  InsightGroupList.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.09.20.
//

import SwiftUI
import TelemetryClient

struct InsightGroupList: View {
    
    @EnvironmentObject var api: APIRepresentative
    var app: TelemetryApp
    var insightGroupID: UUID
    
    @State var isShowingNewInsightGroupView = false
    @State var isShowingNewInsightForm = false
    
    let refreshTimer = Timer.publish(
        every: 5*60, // 5 minutes
        on: .main,
        in: .common
    ).autoconnect()
    
    var body: some View {
        if let insightGroup = (api.insightGroups[app] ?? []).first(where: { $0.id == insightGroupID }) {
            
            ScrollView(.vertical) {
                
                if insightGroup.insights.isEmpty {
                    VStack {
                        Text("This Insight Group is Empty")
                        Button("Delete it") {
                            api.delete(insightGroup: insightGroup, in: app)
                        }
                    }
                } else {
                    
                    InsightsGrid(app: app, insightGroup: insightGroup)
                }
            }
            
            .onAppear {
                api.getInsightGroups(for: app)
                TelemetryManager.shared.send(TelemetrySignal.telemetryAppInsightsShown.rawValue, for: api.user?.email)
            }
            .onReceive(refreshTimer) { _ in
                api.getInsightGroups(for: app)
                TelemetryManager.shared.send(TelemetrySignal.telemetryAppInsightsRefreshed.rawValue, for: api.user?.email)
            }
            .navigationTitle(insightGroup.title)
            .toolbar {
                ToolbarItemGroup {
                    Button(action: {
                        isShowingNewInsightGroupView = true
                    }) {
                        Label("New Insight Group", systemImage: "rectangle.badge.plus")
                    }
                    .sheet(isPresented: $isShowingNewInsightGroupView) {
                        NewInsightGroupView(isPresented: $isShowingNewInsightGroupView, app: app)
                    }
                    
                    Button(action: {
                        isShowingNewInsightForm = true
                    }) {
                        Label("New Insight", systemImage: "plus.viewfinder")
                    }
                    .sheet(isPresented: $isShowingNewInsightForm) {
                        CreateOrUpdateInsightForm(app: app, editMode: false, isPresented: $isShowingNewInsightForm, insight: nil, group: nil)
                            .environmentObject(api)
                    }
                }
            }
        }
    }
}
