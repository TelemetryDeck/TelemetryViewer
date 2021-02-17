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

    @State private var selectedInsightGroupID = UUID()
    @State private var selectedInsightIDValue: UUID?
    @State private var sidebarShownValue: Bool = false
    @State private var sidebarSection: AppRootSidebarSection = .InsightEditor

    #if os(iOS)
        @Environment(\.horizontalSizeClass) var sizeClass
    #endif

    var DefaultSidebarWidth: CGFloat {
        #if os(iOS)
            if sizeClass == .compact {
                return 800
            } else {
                return 350
            }
        #else
            return 280
        #endif
    }

    var DefaultMoveTransition: AnyTransition {
        #if os(iOS)
            if sizeClass == .compact {
                return .move(edge: .bottom)
            } else {
                return .move(edge: .trailing)
            }

        #else
            return .move(edge: .trailing)
        #endif
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    var timeIntervalDescription: String {
        let displayTimeWindowEnd = api.timeWindowEnd ?? Date()
        let displayTimeWindowBegin = api.timeWindowBeginning ??
            displayTimeWindowEnd.addingTimeInterval(-60 * 60 * 24 * 30)

        if api.timeWindowEnd == nil {
            if api.timeWindowBeginning == nil {
                return "Showing Last 30 Days"
            } else {
                let components = Calendar.current.dateComponents([.day], from: displayTimeWindowBegin, to: displayTimeWindowEnd)
                return "Showing Last \(components.day ?? 0) Days"
            }
        } else {
            return "\(dateFormatter.string(from: displayTimeWindowBegin)) – \(dateFormatter.string(from: displayTimeWindowEnd))"
        }
    }

    func reloadVisibleInsights() {
        guard
            let app = app,
            let insightGroup = api.insightGroups[app]?.first(where: { $0.id == selectedInsightGroupID })
        else { return }

        for insight in insightGroup.insights {
            api.getInsightData(for: insight, in: insightGroup, in: app)
        }
    }

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

        let newInsightButton = Button(action: {
            if let app = app, let insightGroup = api.insightGroups[app]?.first(where: { $0.id == selectedInsightGroupID }) {
                let definitionRequestBody = InsightDefinitionRequestBody.new(groupID: selectedInsightGroupID)

                api.create(insightWith: definitionRequestBody, in: insightGroup, for: app) { result in
                    switch result {
                    case let .success(insightDTO):
                        selectedInsightID.wrappedValue = insightDTO.id
                        sidebarSection = .InsightEditor
                    case let .failure(error):
                        print(error)
                    }
                }
            }
        }) {
            Label("New Insight", systemImage: "plus.rectangle")
        }

        AdaptiveStack(spacing: 0) {
            ZStack {
                VStack(spacing: 0) {
                    Divider()

                    if let app = app {
                        if (api.insightGroups[app] ?? []).isEmpty {
                            EmptyAppView(
                                selectedInsightGroupID: $selectedInsightGroupID,
                                sidebarSection: $sidebarSection,
                                sidebarShown: sidebarShown,
                                appID: app.id
                            )
                            .frame(maxWidth: 400)
                            .padding()
                        } else {
                            #if os(iOS)
                                TabView(selection: $selectedInsightGroupID) {
                                    ForEach(api.insightGroups[app] ?? []) { insightGroup in
                                        InsightGroupList(
                                            sidebarSection: $sidebarSection,
                                            sidebarShown: sidebarShown,
                                            selectedInsightID: selectedInsightID,
                                            app: app,
                                            insightGroupID: insightGroup.id
                                        )
                                        .tabItem { Label(insightGroup.title, systemImage: "square.grid.2x2") }
                                        .tag(insightGroup.id)
                                    }
                                }
                                .navigationTitle(app.name)
                            #else
                                Group {
                                    InsightGroupList(
                                        sidebarSection: $sidebarSection,
                                        sidebarShown: sidebarShown,
                                        selectedInsightID: selectedInsightID,
                                        app: app,
                                        insightGroupID: selectedInsightGroupID
                                    )

                                    Divider()

                                    Picker(selection: $selectedInsightGroupID, label: Text("")) {
                                        ForEach(api.insightGroups[app] ?? []) { insightGroup in
                                            Text(insightGroup.title).tag(insightGroup.id)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .padding()
                                }
                            #endif
                        }
                    } else {
                        Text("Please select an App").foregroundColor(.grayColor)
                    }
                }
                .background(Color("CardBackgroundColor"))
                
                #if os(iOS)
                    if sizeClass == .compact && sidebarShownValue {
                        Rectangle()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .opacity(0.2)
                            .onTapGesture {
                                withAnimation {
                                    selectedInsightIDValue = nil
                                    sidebarShownValue = false
                                }
                            }
                    }
                #endif
            }
            .onAppear {
                if let app = app {
                    selectedInsightGroupID = api.insightGroups[app]?.first?.id ?? UUID()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if sidebarShownValue {
                DetailSidebar(isOpen: sidebarShown, maxWidth: DefaultSidebarWidth) {
                    AppRootSidebar(selectedInsightID: selectedInsightID, selectedInsightGroupID: $selectedInsightGroupID, sidebarSection: $sidebarSection, appID: appID)
                }
                .edgesIgnoringSafeArea(.bottom)
                .transition(DefaultMoveTransition)
            }
        }
        .toolbar {
            ToolbarItem {
                Menu {
                    Section {
                        Button(action: {
                            api.timeWindowBeginning = Date().addingTimeInterval(-60 * 60 * 24 * 365)
                            api.timeWindowEnd = nil
                            reloadVisibleInsights()
                        }) {
                            Label("Last Year", systemImage: "calendar")
                        }

                        Button(action: {
                            api.timeWindowBeginning = nil
                            api.timeWindowEnd = nil
                            reloadVisibleInsights()
                        }) {
                            Label("Last Month", systemImage: "calendar")
                        }

                        Button(action: {
                            api.timeWindowBeginning = Date().addingTimeInterval(-60 * 60 * 24 * 7)
                            api.timeWindowEnd = nil
                            reloadVisibleInsights()
                        }) {
                            Label("Last Week", systemImage: "calendar")
                        }

                        Button(action: {
                            api.timeWindowBeginning = Date().addingTimeInterval(-60 * 60 * 24)
                            api.timeWindowEnd = nil
                            reloadVisibleInsights()
                        }) {
                            Label("Today", systemImage: "calendar")
                        }
                    }

                    #if os(iOS)
                        if sizeClass == .compact {
                            Divider()

                            newInsightButton

                            Divider()

                            Button(action: {
                                withAnimation { sidebarShown.wrappedValue.toggle() }
                            }) {
                                Label("Toggle Editor", systemImage: "square.bottomhalf.fill")
                            }
                        }
                    #endif
                }
                label: {
                    #if os(iOS)
                        if sizeClass == .compact {
                            HStack {
                                Text(timeIntervalDescription)
                                Divider()
                                Image(systemName: "ellipsis")
                            }
                        } else {
                            Text(timeIntervalDescription)
                        }
                    #else
                        Text(timeIntervalDescription)
                    #endif
                }
            }

            ToolbarItem {
                newInsightButton
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
