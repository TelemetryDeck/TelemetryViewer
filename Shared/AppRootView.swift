//
//  AppRootView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.11.20.
//

import SwiftUI

struct AppRootView: View {
    @EnvironmentObject var api: APIRepresentative
    let appID: UUID
    
    @State private var selectedView = 0
    
    @State var isShowingNewInsightGroupView = false
    @State var isShowingNewInsightForm = false
    
    var body: some View {
        Group {
            if let app = api.app(with: appID) {
                switch selectedView {
                case 0:
                    TabView {
                        if (api.insightGroups[app] ?? []).isEmpty {
                            OfferDefaultInsights(app: app)
                                .tabItem { Label("Start Here", systemImage: "wand.and.stars") }
                        }
                        
                        ForEach(api.insightGroups[app] ?? []) { insightGroup in
                            InsightGroupList(app: app, insightGroupID: insightGroup.id)
                                .tabItem { Label(insightGroup.title, systemImage: "square.grid.2x2") }
                        }
                    }
                    .navigationTitle(app.name)
                case 1:
                    LexiconView(app: app)
                case 2:
                    SignalList(app: app)
                case 3:
                    AppSettingsView(app: app)
                default:
                    Text("You should never see this.")
                }
            }
            else {
                Text("This app does not exist.")
            }
        }
        .toolbar {
            ToolbarItemGroup {
                if let app = api.app(with: appID) {
                    Button(action: {
                        isShowingNewInsightGroupView = true
                    }) {
                        Label("New Insight Group", systemImage: "rectangle.badge.plus")
                    }
                    .sheet(isPresented: $isShowingNewInsightGroupView) {
                        NewInsightGroupView(app: app)
                    }
                    
                    Button(action: {
                        isShowingNewInsightForm = true
                    }) {
                        Label("New Insight", systemImage: "plus.viewfinder")
                    }
                    .sheet(isPresented: $isShowingNewInsightForm) {
                        CreateOrUpdateInsightForm(app: app, editMode: false, insight: nil, group: nil)
                            .environmentObject(api)
                    }
                }
            }
            
            ToolbarItem {
                Picker(selection: $selectedView, label: Text("Display Mode")) {
                    Image(systemName: "square.dashed.inset.fill").tag(0)
                    Image(systemName: "book").tag(1)
                    Image(systemName: "waveform").tag(2)
                    Image(systemName: "gear").tag(3)
                }.pickerStyle(SegmentedPickerStyle())
            }
            

        }
    }
}
