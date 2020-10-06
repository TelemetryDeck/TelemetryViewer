//
//  InsightGroupList.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.09.20.
//

import SwiftUI

struct InsightGroupList: View {
    @EnvironmentObject var api: APIRepresentative
    var app: TelemetryApp
    
    @State var isShowingRawSignalsView = false
    @State var isShowingNewInsightGroupView = false
    @State var isShowingNewInsightForm = false
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], alignment: .leading) {
                if let insightGroups = api.insightGroups[app] {
                    ForEach(insightGroups, id: \.id) { insightGroup in
                        Section(header: HStack {
                            Text(insightGroup.title).font(.title)
                            Button(
                                action: { api.delete(insightGroup: insightGroup, in: app) },
                                label: { Image(systemName: "xmark.circle.fill") })
                            
                        }) {
                            ForEach(insightGroup.insights, id: \.id) { insight in
                                ZStack(alignment: Alignment.topTrailing) {
                                    CardView {
                                        InsightView(app: app, insightGroup: insightGroup, insight: insight)
                                            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                    }
                                    
                                    
                                    Button(
                                        action: {
                                            api.delete(insight: insight, in: insightGroup, in: app)
                                        },
                                        label: {
                                            Image(systemName: "xmark.circle.fill")
                                        })
                                        .offset(x: -10, y: 10)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear {
            api.getInsightGroups(for: app)
            TelemetryManager().send(.telemetryAppInsightsShown, for: api.user?.email)
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
                    NewInsightForm(app: app, isPresented: $isShowingNewInsightForm)
                }
                
                Button(action: {
                    isShowingRawSignalsView = true
                }) {
                    Label("Raw Signals", systemImage: "waveform")
                }
                .sheet(isPresented: $isShowingRawSignalsView) {
                    SignalList(isPresented: $isShowingRawSignalsView, app: app)
                }
            }
        }
    }
}

struct InsightGroupList_Previews: PreviewProvider {
    static var previews: some View {
        InsightGroupList(app: MockData.app1)
    }
}
