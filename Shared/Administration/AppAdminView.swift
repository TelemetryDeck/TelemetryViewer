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
        let section1 = api.appAdminSignalCounts.filter { $0.userCount > 10000 }
        let section2 = api.appAdminSignalCounts.filter { 100 < $0.userCount && $0.userCount <= 10000 }
        let section3 = api.appAdminSignalCounts.filter { $0.userCount <= 100 }
        
        List {
            HStack {
                ValueUnitAndTitleView(value: Double(api.appAdminSignalCounts.count), title: "Active Apps")
                Divider()
                ValueUnitAndTitleView(value: Double(section1.count), title: "Big Ones")
                Divider()
                ValueUnitAndTitleView(value: Double(section2.count), title: "Medium Ones")
                Divider()
                ValueUnitAndTitleView(value: Double(section3.count), title: "Small Ones")
            }
            
            Section(header: Text("> 10.000 users")) {
                ForEach(section1) { a in
                    AddAdminViewListEntry(appSignalCountDTO: a)
                }
            }
            
            Section(header: Text("> 100 users")) {
                ForEach(section2) { a in
                    AddAdminViewListEntry(appSignalCountDTO: a)
                }
            }
            
            Section(header: Text("<= 100 users")) {
                ForEach(section3) { a in
                    AddAdminViewListEntry(appSignalCountDTO: a)
                }
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
                
                Text("\(appSignalCountDTO.signalCount)").animatableNumber(value: Double(appSignalCountDTO.signalCount), shouldFormatBigNumbers: true).opacity(0.5)
                Text("\(appSignalCountDTO.userCount)").animatableNumber(value: Double(appSignalCountDTO.userCount), shouldFormatBigNumbers: true)
            }
        }
    }
}

struct AppAdminDetailView: View {
    let entry: AppSignalCountDTO

    var body: some View {
        ScrollView {
            HStack {
                ValueUnitAndTitleView(value: Double(entry.signalCount), title: "Signals", shouldFormatBigNumbers: true)
                Divider()
                ValueUnitAndTitleView(value: Double(entry.userCount), title: "Users", shouldFormatBigNumbers: true)
            }
            
            Divider()
            
            CustomSection(header: Text(entry.appName ?? "App"), summary: EmptyView(), footer: EmptyView(), startCollapsed: true) {
                Text(entry.id.uuidString)
                Button("Copy to Clipboard") {
                    saveToClipBoard(entry.id.uuidString)
                }
                .buttonStyle(SmallSecondaryButtonStyle())
            }
            
            CustomSection(header: Text(entry.organisationName ?? "Organisation"), summary: EmptyView(), footer: EmptyView(), startCollapsed: true) {
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
