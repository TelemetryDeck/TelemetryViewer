//
//  AppRootView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.11.20.
//

import SwiftUI

enum AppRootSidebarSection {
    case InsightEditor
    case InsightGroupEditor
    case AppEditor
    case Lexicon
    case RawSignals
}

struct AppRootView: View {
    let appID: UUID
    private var app: TelemetryApp? { api.apps.first(where: { $0.id == appID }) }

    @EnvironmentObject var api: APIRepresentative

    @State private var selectedInsightGroupID: UUID = UUID()
    @State private var selectedInsightIDValue: UUID?
    @State private var sidebarShownValue: Bool = false
    @State private var sidebarSection: AppRootSidebarSection = .InsightEditor

    var body: some View {
        let selectedInsightID = Binding<UUID?>(get: {
            self.selectedInsightIDValue
        }, set: {
            self.selectedInsightIDValue = $0
            withAnimation { self.sidebarShownValue = self.selectedInsightIDValue != nil }
        })

        let sidebarShown = Binding<Bool>(get: {
            self.sidebarShownValue
        }, set: {
            self.sidebarShownValue = $0
            if !$0 {
                self.selectedInsightIDValue = nil
            }
        })

        HStack(spacing: 0) {
            Group {
                if let app = app {
                    TabView(selection: $selectedInsightGroupID) {
                        if (api.insightGroups[app] ?? []).isEmpty {
                            OfferDefaultInsights(app: app)
                                .tabItem { Label("Start Here", systemImage: "wand.and.stars") }
                        }

                        ForEach(api.insightGroups[app] ?? []) { insightGroup in
                            InsightGroupList(selectedInsightID: selectedInsightID, app: app, insightGroupID: insightGroup.id)
                                .tabItem { Label(insightGroup.title, systemImage: "square.grid.2x2") }
                                .tag(insightGroup.id)
                        }
                    }
                    .navigationTitle(app.name)
                } else {
                    Text("Not an App")
                }
            }
            .onAppear() {
                if let app = app {
                    selectedInsightGroupID = api.insightGroups[app]?.first?.id ?? UUID()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)


            if sidebarShownValue {
                DetailSidebar(isOpen: sidebarShown , maxWidth: 350) {
                    AppRootSidebar(selectedInsightID: selectedInsightID, selectedInsightGroupID: $selectedInsightGroupID, sidebarSection: $sidebarSection, appID: appID)
                }
                .edgesIgnoringSafeArea(.bottom)
                .transition(.move(edge: .trailing))
            }
        }
        .toolbar {
            ToolbarItem {
                if let app = app, let insightGroup = api.insightGroups[app]?.first(where: { $0.id == selectedInsightGroupID }) {
                    Button(action: {
                        let definitionRequestBody = InsightDefinitionRequestBody(
                            order: nil,
                            title: "New Insight",
                            subtitle: nil,
                            signalType: nil,
                            uniqueUser: false,
                            filters: [:],
                            rollingWindowSize: -2592000,
                            breakdownKey: nil,
                            displayMode: .lineChart,
                            groupID: selectedInsightGroupID,
                            id: nil,
                            isExpanded: false)

                        api.create(insightWith: definitionRequestBody, in: insightGroup, for: app) { result in
                            switch result {
                            case .success(let insightDTO):
                                selectedInsightID.wrappedValue = insightDTO.id
                                sidebarSection = .InsightEditor
                            case .failure(let error):
                                print(error)
                            }

                        }
                    }) {
                        Label("New Insight", systemImage: "plus.rectangle")
                    }



                }
            }

            ToolbarItem {
                Button(action: {
                    withAnimation { sidebarShown.wrappedValue.toggle() }
                }) {
                    Label("Toggle Sidebar", systemImage: "sidebar.trailing")
                }
            }
        }
    }
}

struct AppRootSidebar: View {
    @Binding var selectedInsightID: UUID?
    @Binding var selectedInsightGroupID: UUID
    @Binding var sidebarSection: AppRootSidebarSection
    @EnvironmentObject var api: APIRepresentative

    var appID: UUID

    var body: some View {

        VStack {
            Picker(selection: $sidebarSection, label: Text("")) {
                Image(systemName: "app.fill").tag(AppRootSidebarSection.InsightEditor)
                Image(systemName: "square.grid.2x2.fill").tag(AppRootSidebarSection.InsightGroupEditor)
                Image(systemName: "gear").tag(AppRootSidebarSection.AppEditor)
                Image(systemName: "book").tag(AppRootSidebarSection.Lexicon)
                Image(systemName: "waveform").tag(AppRootSidebarSection.RawSignals)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom)
            .padding(.horizontal)

            switch sidebarSection {
            case .InsightEditor:
                InsightEditor(viewModel: InsightEditorViewModel(api: api, appID: appID, selectedInsightGroupID: $selectedInsightGroupID, selectedInsightID: $selectedInsightID))
            case .InsightGroupEditor:
                InsightGroupEditor(viewModel: InsightGroupEditorViewModel(api: api, appID: appID, selectedInsightGroupID: $selectedInsightGroupID, selectedInsightID: $selectedInsightID, sidebarSection: $sidebarSection))
            case .AppEditor:
                AppEditor(appID: appID, selectedInsightGroupID: $selectedInsightGroupID, sidebarSection: $sidebarSection)
            case .Lexicon:
                LexiconView(appID: appID)
            case .RawSignals:
                SignalList(appID: appID)
            }

            Spacer()
        }
    }
}
