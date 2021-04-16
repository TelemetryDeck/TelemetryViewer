//
//  OrganizationAdmin.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 07.12.20.
//

import SwiftUI
import TelemetryModels

struct AppAdminView: View {
    @EnvironmentObject var api: APIRepresentative
    @State private var isLoading: Bool = false

    let refreshTimer = Timer.publish(
        every: 1 * 60, // 1 minute
        on: .main,
        in: .common
    ).autoconnect()
    
    func refreshAppSignalCounts() {
        isLoading = true
        api.getAppSignalCounts { _ in
            self.isLoading = false
        }
    }

    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return formatter
    }()

    var body: some View {
        List {
            ForEach(api.appAdminSignalCounts) { a in
                AddAdminViewListEntry(appSignalCountDTO: a)
            }
        }
        .toolbar {
            if isLoading {
                ProgressView()
                    .scaleEffect(0.5, anchor: .center)
            } else {
                Button(action: refreshAppSignalCounts, label: {
                    Image(systemName: "arrow.counterclockwise.circle")
                })
            }
        }
        .navigationTitle("App Admin")
        .onAppear { refreshAppSignalCounts() }
        .onReceive(refreshTimer) { _ in refreshAppSignalCounts() }
    }
}


struct AddAdminViewListEntry: View {
    let appSignalCountDTO: AppSignalCountDTO
    
    var body: some View {
        NavigationLink(destination: AppAdminDetailView(entry: appSignalCountDTO)) {
            HStack {
                Text(appSignalCountDTO.appName ?? "–")
                
                appSignalCountDTO.organisationName.map {
                    Text($0).opacity(0.5)
                }
                
                Spacer()
                Text("\(appSignalCountDTO.signalCount)")
            }
        }
    }
}

struct AppAdminDetailView: View {
    let entry: AppSignalCountDTO

    var body: some View {
        ScrollView {
            ValueView(value: Double(entry.signalCount), title: "Signals", shouldFormatBigNumbers: true)
            
            Divider()
            
            CustomSection(header: Text(entry.appName ?? "App"), summary: EmptyView(), footer: EmptyView()) {
                Text(entry.id.uuidString)
                Button("Copy to Clipboard") {
                    saveToClipBoard(entry.id.uuidString)
                }
                .buttonStyle(SmallSecondaryButtonStyle())
            }
            
            CustomSection(header: Text(entry.organisationName ?? "Organisation"), summary: EmptyView(), footer: EmptyView()) {
                Text(entry.organisationID?.uuidString ?? "-")
                Button("Copy to Clipboard") {
                    saveToClipBoard(entry.organisationID?.uuidString ?? "–")
                }
                .buttonStyle(SmallSecondaryButtonStyle())
            }
        }
        .padding()
    }
}
