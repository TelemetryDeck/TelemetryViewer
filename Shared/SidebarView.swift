//
//  SidebarView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 10.08.20.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var api: APIRepresentative
    @Binding var selectedApp: TelemetryApp?
    @State var isCreatingANewApp: Bool = false
    
    func section(for app: TelemetryApp) -> some View {
        Section(header: Text(app.name)) {
            ForEach(api.insightGroups[app] ?? []) { insightGroup in
                NavigationLink(
                    destination: InsightGroupList(app: app, insightGroupID: insightGroup.id),
                    label: {
                        Label(insightGroup.title, systemImage: "square.grid.2x2")
                    }
                )
            }
            
            if (api.insightGroups[app] ?? []).isEmpty {
                NavigationLink(
                    destination: OfferDefaultInsights(app: app),
                    label: {
                        Label("Start Here", systemImage: "wand.and.stars")
                    }
                )
            }
            
            NavigationLink(
                destination: LexiconView(app: app),
                label: {
                    Label("Lexicon", systemImage: "book")
                }
            )
            
            NavigationLink(
                destination: SignalList(app: app),
                label: {
                    Label("Raw Signals", systemImage: "waveform")
                }
            )
            
            NavigationLink(
                destination: AppSettingsView(app: app),
                label: {
                    Label("Settings", systemImage: "gear")
                }
            )   
        }
    }
    
    var body: some View {
        List(selection: $selectedApp) {
            
            ForEach(Array(api.apps), id: \.self) { app in
                section(for: app)
            }
            
            Section(header: Text("You")) {
                
                if let apiUser = api.user {
                    
                    NavigationLink(destination: UserSettingsView(), label: {
                        Label("\(apiUser.firstName) \(apiUser.lastName)", systemImage: "person.circle")
                    })
                    
                    
                    NavigationLink(destination: OrganizationSettingsView(), label: {
                        Label(apiUser.organization?.name ?? "Unknown Org", systemImage: "app.badge")
                    })
                } else {
                    Label("firstName lastName", systemImage: "person.circle").redacted(reason: .placeholder)
                    Label("organization.name", systemImage: "app.badge").redacted(reason: .placeholder)
                }
            }
            
            if api.user?.organization?.isSuperOrg == true {
                Section(header: Text("Administration")) {
                    NavigationLink(
                        destination: BetaRequestsList(),
                        label: {
                            Label("Beta Requests", systemImage: "app.badge")
                        }
                    )
                }
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Telemetry")
        .onAppear {
            selectedApp = api.apps.first
        }
        .toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.primaryAction) {
                HStack {
                    Button(action: {
                        isCreatingANewApp = true
                    }) {
                        Label("New App", systemImage: "plus.app.fill")
                    }
                    .sheet(isPresented: $isCreatingANewApp) {
                        NewAppView(isPresented: $isCreatingANewApp)
                    }
                }
            }
        }
    }
}
