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

struct AppRootView: View {
    let appID: UUID
    private var app: TelemetryApp? { api.apps.first(where: { $0.id == appID }) }

    @EnvironmentObject var api: APIRepresentative

    @State private var selectedInsightGroupID: UUID = UUID()
    @State private var selectedInsightIDValue: UUID?
    @State private var sidebarShownValue: Bool = false
    @State private var sidebarSection: AppRootSidebarSection = .InsightEditor

    #if os(iOS)
    @Environment(\.horizontalSizeClass) var sizeClass
    #endif

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    var timeIntervalDescription: String {
        let displayTimeWindowEnd = api.timeWindowEnd ?? Date()
        let displayTimeWindowBegin = api.timeWindowBeginning ?? displayTimeWindowEnd.addingTimeInterval(-60 * 60 * 24 * 30)

        if api.timeWindowEnd == nil {
            if api.timeWindowBeginning == nil {
                return "Showing Last 30 Days"
            } else {
                let components = Calendar.current.dateComponents([.day], from: displayTimeWindowBegin, to: displayTimeWindowEnd)
                return "Showing Last \(components.day ?? 0) Days" // TODO
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

        AdaptiveStack(spacing: 0) {
            Group {
                VStack(spacing: 0) {
                    Divider()

                if let app = app {
                    if (api.insightGroups[app] ?? []).isEmpty {
                        EmptyAppView().frame(maxWidth: 400)
                    } else {

                        #if os(iOS)
                        TabView(selection: $selectedInsightGroupID) {
                            ForEach(api.insightGroups[app] ?? []) { insightGroup in
                                InsightGroupList(selectedInsightID: selectedInsightID, app: app, insightGroupID: insightGroup.id)
                                    .tabItem { Label(insightGroup.title, systemImage: "square.grid.2x2") }
                                    .tag(insightGroup.id)
                            }
                        }
                        .navigationTitle(app.name)
                        #else
                        Group {
                            InsightGroupList(selectedInsightID: selectedInsightID, app: app, insightGroupID: selectedInsightGroupID)

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
            }
            .onAppear() {
                if let app = app {
                    selectedInsightGroupID = api.insightGroups[app]?.first?.id ?? UUID()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)


            if sidebarShownValue {
                DetailSidebar(isOpen: sidebarShown , maxWidth: DefaultSidebarWidth) {

                    #if os(iOS)
                    if sizeClass == .compact {
                        VStack {
                            Divider()
                                .padding(.bottom)
                            Button(action: {
                                withAnimation { sidebarShown.wrappedValue.toggle() }
                            }) {
                                Label("Hide Editor", systemImage: "sidebar.trailing")
                            }
                            AppRootSidebar(selectedInsightID: selectedInsightID, selectedInsightGroupID: $selectedInsightGroupID, sidebarSection: $sidebarSection, appID: appID)
                        }
                    } else {
                        AppRootSidebar(selectedInsightID: selectedInsightID, selectedInsightGroupID: $selectedInsightGroupID, sidebarSection: $sidebarSection, appID: appID)
                    }
                    #else
                    AppRootSidebar(selectedInsightID: selectedInsightID, selectedInsightGroupID: $selectedInsightGroupID, sidebarSection: $sidebarSection, appID: appID)
                    #endif


                }
                .edgesIgnoringSafeArea(.bottom)
                .transition(DefaultMoveTransition)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
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
                }
                label: {
                    Text(timeIntervalDescription)
                }
            }

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
            Divider()

            Picker(selection: $sidebarSection, label: Text("")) {
                Image(systemName: "app.fill").tag(AppRootSidebarSection.InsightEditor)
                Image(systemName: "square.grid.2x2.fill").tag(AppRootSidebarSection.InsightGroupEditor)
                Image(systemName: "app").tag(AppRootSidebarSection.AppEditor)
                Image(systemName: "book").tag(AppRootSidebarSection.Lexicon)
                Image(systemName: "waveform").tag(AppRootSidebarSection.RawSignals)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            Divider()

            switch sidebarSection {
            case .InsightEditor:
                InsightEditorContainer(viewModel: InsightEditorContainerViewModel(api: api, appID: appID, selectedInsightGroupID: $selectedInsightGroupID, selectedInsightID: $selectedInsightID))
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

struct EmptyAppView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image("arrow-left-right-up")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 300)
            Text("A new App! Awesome!")
                .font(.title)
                .foregroundColor(.grayColor)
            Text("Next steps:\n\n1. Now open the side bar 􀏛\n2. select the app section 􀑋\n3. create a new Insight Group.")
                .foregroundColor(.grayColor)

            HStack {
                Button("Telemetry Swift Client") {
                    #if os(macOS)
                    NSWorkspace.shared.open(URL(string: "https://github.com/AppTelemetry/SwiftClient")!)
                    #else
                    UIApplication.shared.open(URL(string: "https://github.com/AppTelemetry/SwiftClient")!)
                    #endif
                }
                .buttonStyle(SmallSecondaryButtonStyle())

                Button("Documentation: Sending Signals") {
                    #if os(macOS)
                    NSWorkspace.shared.open(URL(string: "https://apptelemetry.io/pages/quickstart.html")!)
                    #else
                    UIApplication.shared.open(URL(string: "https://apptelemetry.io/pages/quickstart.html")!)
                    #endif
                }
                .buttonStyle(SmallSecondaryButtonStyle())
            }
            Spacer()
        }
    }
}
