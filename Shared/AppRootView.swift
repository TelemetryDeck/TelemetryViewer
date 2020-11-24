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

    var body: some View {
        if let app = api.apps.first(where: { $0.id == appID }), let insightGroup = api.insightGroups[app]?.first {
            InsightsGrid(app: app, insightGroup: insightGroup)

        } else {
            Text("The App no longer exists")
        }
    }
}

struct AppRootView2: View {
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var sizeClass
    #endif
    
    @EnvironmentObject var api: APIRepresentative
    let appID: UUID
    
    @State private var selectedView = 0
    
    @State var isShowingNewInsightGroupView = false
    @State var isShowingNewInsightForm = false
    
    var body: some View {
        let group = Group {
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
        
        let newGroupButton = Button(action: {
            isShowingNewInsightGroupView = true
        }) {
            Label("New Insight Group", systemImage: "rectangle.badge.plus")
        }
        .sheet(isPresented: $isShowingNewInsightGroupView) {
            NewInsightGroupView(app: api.app(with: appID)!)
        }
        
        
        let newInsightButton = Button(action: {
            isShowingNewInsightForm = true
        }) {
            Label("New Insight", systemImage: "plus.viewfinder")
        }
        .sheet(isPresented: $isShowingNewInsightForm) {
            CreateOrUpdateInsightForm(app: api.app(with: appID)!, editMode: false, insight: nil, group: nil)
                .environmentObject(api)
        }
        
        let picker = Picker(selection: $selectedView, label: Text("Display Mode")) {
            Image(systemName: "square.dashed.inset.fill").tag(0)
            Image(systemName: "book").tag(1)
            Image(systemName: "waveform").tag(2)
            Image(systemName: "gear").tag(3)
        }.pickerStyle(SegmentedPickerStyle())
        
        
        
        #if os(iOS)
        if sizeClass == .compact {
            group
                .toolbar {
                    ToolbarItem {
                        HStack(spacing: 10) {
                            newGroupButton
                            newInsightButton
                            picker
                        }
                    }
                }
        } else {
            group
                .toolbar {
                    ToolbarItemGroup {
                        newGroupButton
                        newInsightButton
                    }
                    
                    ToolbarItem {
                        picker
                    }
                }
        }
        #else
        group
            .toolbar {
                ToolbarItemGroup {
                    newGroupButton
                    newInsightButton
                }
                
                ToolbarItem {
                    picker
                }
            }
        #endif
    }
    
}
