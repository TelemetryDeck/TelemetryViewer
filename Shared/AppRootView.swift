//
//  AppRootView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.11.20.
//

import SwiftUI

enum SidebarElement: Equatable {
    case app(id: UUID)
    case insightGroup(id: UUID)
    case insight(id: UUID)
}

struct AppRootView: View {
    let appID: UUID
    private var app: TelemetryApp? { api.apps.first(where: { $0.id == appID }) }

    @EnvironmentObject var api: APIRepresentative

    @State private var sidebarElementValue: SidebarElement?
    @State private var sidebarShownValue: Bool = false


    var body: some View {
        let sidebarElement = Binding<SidebarElement?>(get: {
            self.sidebarElementValue
        }, set: {
            self.sidebarElementValue = $0
            withAnimation { self.sidebarShownValue = self.sidebarElementValue != nil }
        })

        let sidebarShown = Binding<Bool>(get: {
            self.sidebarShownValue
        }, set: {
            self.sidebarShownValue = $0
            if !$0 {
                self.sidebarElementValue = nil
            }
        })

        HStack {
            Group {
                if let app = app {
                    TabView {
                        if (api.insightGroups[app] ?? []).isEmpty {
                            OfferDefaultInsights(app: app)
                                .tabItem { Label("Start Here", systemImage: "wand.and.stars") }
                        }

                        ForEach(api.insightGroups[app] ?? []) { insightGroup in
                            InsightGroupList(sidebarElement: sidebarElement, app: app, insightGroupID: insightGroup.id)
                                .tabItem { Label(insightGroup.title, systemImage: "square.grid.2x2") }
                        }
                    }
                    .navigationTitle(app.name)
                } else {
                    Text("Not an App")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)


            if sidebarShownValue {
                DetailSidebar(isOpen: sidebarShown , maxWidth: 350) {
                    AppRootSidebar(sidebarElement: sidebarElement, appID: appID)
                }.transition(.move(edge: .trailing))
            }
        }
        .toolbar {
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
    @Binding var sidebarElement: SidebarElement?

    @State var editorMode: Int = 0

    var appID: UUID

    var body: some View {

        VStack {
            Picker(selection: $editorMode, label: Text("")) {
                Image(systemName: "app.fill").tag(0)
                Image(systemName: "square.grid.2x2.fill").tag(1)
                Image(systemName: "gear").tag(2)
                Image(systemName: "book").tag(3)
                Image(systemName: "waveform").tag(4)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom)

            switch editorMode {
            case 0:
                SelectionEditor(sidebarElement: $sidebarElement)
            case 1:
                Text("Insight Group Seettings")
            case 2:
                AppSettingsView(appID: appID, sidebarElement: $sidebarElement)
            case 3:
                LexiconView(appID: appID)
            case 4:
                SignalList(appID: appID)
            default:
                Text("Unknown Selection")
            }

            Spacer()
        }
    }
}

struct SelectionEditor: View {
    @Binding var sidebarElement: SidebarElement?

    var body: some View {
        switch sidebarElement {
        case .app(let id):
            Text("App \(id)")
        case .insightGroup(let id):
            Text("Insight Group \(id)")
        case .insight(let id):
            InsightEditor(insightID: id)
        case .none:
            Text("Nothing Selected").foregroundColor(.grayColor)
        }
    }
}

struct InsightEditor: View {
    let insightID: UUID
    @EnvironmentObject var api: APIRepresentative

    var insightDTO: InsightDataTransferObject? {
        api.insightData[insightID]
    }

    var body: some View {
        if let insightDTO = insightDTO {
            Text("Insight \(insightDTO.title)")
        } else {
            Text("No Insight Here")
        }
    }
}
