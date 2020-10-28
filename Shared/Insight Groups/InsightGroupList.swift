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
    
    @State var isShowingRawSignalsView = false
    @State var isShowingNewInsightGroupView = false
    @State var isShowingNewInsightForm = false
    @State var isShowingAppSettingsView: Bool = false
    
    let refreshTimer = Timer.publish(
        every: 5*60, // 5 minutes
        on: .main,
        in: .common
    ).autoconnect()
    
    var body: some View {
        Group {
            if let insightGroups = api.insightGroups[app] {
                if insightGroups.isEmpty {
                    OfferDefaultInsights(app: app)
                        .frame(maxWidth: 600)
                        .padding()
                }
                
                else {
                    ScrollView(.vertical) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], alignment: .leading) {
                            ForEach(insightGroups.sorted(by: { $0.order ?? 0 < $1.order ?? 0 }), id: \.id) { insightGroup in
                                Section(header: HStack {
                                    Text(insightGroup.title).font(.title)
                                    
                                    if insightGroup.insights.isEmpty {
                                        Button(
                                            action: { api.delete(insightGroup: insightGroup, in: app) },
                                            label: { Image(systemName: "xmark.circle.fill") })
                                    }
                                    
                                }) {
                                    ForEach(insightGroup.insights.sorted(by: { $0.order ?? 0 < $1.order ?? 0 }), id: \.id) { insight in
                                        CardView {
                                            InsightView(app: app, insightGroup: insightGroup, insight: insight)
                                                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                        }
                                    }
                                }
                            }.animation(.easeInOut)
                            
                            
                        }
                        .padding()
                    }
                }
            }
            
            else {
                ProgressView()
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
        .navigationTitle(app.name)
        .toolbar {
            HStack {
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
                
                Button(action: {
                    isShowingRawSignalsView = true
                }) {
                    Label("Raw Signals", systemImage: "waveform")
                }
                .sheet(isPresented: $isShowingRawSignalsView) {
                    SignalList(isPresented: $isShowingRawSignalsView, app: app)
                }
                
                Button(action: {
                    isShowingAppSettingsView = true
                }) {
                    Label("App Settings", systemImage: "gear")
                }
                .sheet(isPresented: $isShowingAppSettingsView) {
                    AppSettingsView(isPresented: $isShowingAppSettingsView, app: app)
                        .environmentObject(api)
                }
            }
        }
    }
}
