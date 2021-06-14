//
//  OrganizationAdmin.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 07.12.20.
//

import SwiftUI

private enum DisplayMode: Hashable {
    case users, signals
}

struct AppAdminView: View {
    @EnvironmentObject var api: APIClient
    @State private var isLoading: Bool = false
    @State private var displayMode: DisplayMode = .signals
    
    let section1LowerUsers = 25_000.0
    let section2LowerUsers = 5000.0
    let section3LowerUsers = 10.0
    
    let section1LowerSignals = 5_000_000.0
    let section2LowerSignals = 100_000.0
    let section3LowerSignals = 100.0

    let refreshTimer = Timer.publish(
        every: 1 * 60, // 1 minute
        on: .main,
        in: .common
    ).autoconnect()
    
    func refreshAppAdminEntrys() {
        isLoading = true
        api.getAppAdminEntrys { _ in
            self.isLoading = false
        }
    }

    var body: some View {
        let section1 = api.appAdminSignalCounts.filter {
            switch displayMode {
            case .users:
                return Double($0.userCount) > section1LowerUsers
            case .signals:
                return Double($0.signalCount) > section1LowerSignals
            }
        }
        
        let section2 = api.appAdminSignalCounts.filter {
            switch displayMode {
            case .users:
                return section2LowerUsers < Double($0.userCount) && Double($0.userCount) <= section1LowerUsers
            case .signals:
                return section2LowerSignals < Double($0.signalCount) && Double($0.signalCount) <= section1LowerSignals
            }
        }
        
        let section3 = api.appAdminSignalCounts.filter {
            switch displayMode {
            case .users:
                return section3LowerUsers < Double($0.userCount) && Double($0.userCount) <= section2LowerUsers
            case .signals:
                return section3LowerSignals < Double($0.signalCount) && Double($0.signalCount) <= section2LowerSignals
            }
        }
        
        let section4 = api.appAdminSignalCounts.filter {
            switch displayMode {
            case .users:
                return Double($0.userCount) <= section3LowerUsers
            case .signals:
                return Double($0.signalCount) <= section3LowerSignals
            }
        }
        
        List {
            HStack {
                ValueUnitAndTitleView(value: Double(api.appAdminSignalCounts.count), title: "Active Apps")
                Divider()
                ValueUnitAndTitleView(value: Double(section4.count), title: "Explorers")
                Divider()
                ValueUnitAndTitleView(value: Double(section3.count), title: "Free Tier")
                Divider()
                ValueUnitAndTitleView(value: Double(section2.count), title: "Tier 1")
                Divider()
                ValueUnitAndTitleView(value: Double(section1.count), title: "Tier 2")
            }
            
            Section(header: Text(displayMode == .users ? "> \(Int(section1LowerUsers)) users" : "> \(Int(section1LowerSignals)) signals")) {
                ForEach(section1) { a in
                    AddAdminViewListEntry(appSignalCountDTO: a, displayMode: displayMode)
                }
            }
            
            Section(header: Text(displayMode == .users ? "> \(Int(section2LowerUsers)) users" : "> \(Int(section2LowerSignals)) signals")) {
                ForEach(section2) { a in
                    AddAdminViewListEntry(appSignalCountDTO: a, displayMode: displayMode)
                }
            }
            
            Section(header: Text(displayMode == .users ? "<= \(Int(section2LowerUsers)) users" : "<= \(Int(section2LowerSignals)) signals")) {
                ForEach(section3) { a in
                    AddAdminViewListEntry(appSignalCountDTO: a, displayMode: displayMode)
                }
            }
            
            Section(header: Text(displayMode == .users ? "<= \(Int(section3LowerUsers)) users" : "<= \(Int(section3LowerSignals)) signals")) {
                ForEach(section4) { a in
                    AddAdminViewListEntry(appSignalCountDTO: a, displayMode: displayMode)
                }
            }
        }
        .toolbar {
            if isLoading {
                ProgressView()
                    .scaleEffect(progressViewScaleLarge, anchor: .center)
            } else {
                Button(action: {
                    withAnimation {
                        switch displayMode {
                        case .users:
                            displayMode = .signals
                        case .signals:
                            displayMode = .users
                        }
                    }
                }, label: {
                    switch displayMode {
                    case .users:
                        Text("Users")
                    case .signals:
                        Text("Signals")
                    }
                })
                
                #if os(macOS)
                Button(action: refreshAppAdminEntrys, label: {
                    Image(systemName: "arrow.counterclockwise.circle")
                })
                #endif
            }
        }
        .navigationTitle("App Admin")
        .onAppear { refreshAppAdminEntrys() }
        .onReceive(refreshTimer) { _ in refreshAppAdminEntrys() }
    }
}

private struct AddAdminViewListEntry: View {
    let appSignalCountDTO: DTO.AppAdminEntry
    let displayMode: DisplayMode
    
    var body: some View {
        NavigationLink(destination: AppAdminDetailView(entry: appSignalCountDTO)) {
            HStack {
                Text(appSignalCountDTO.appName ?? "–")
                
                appSignalCountDTO.organisationName.map {
                    Text($0).opacity(0.5)
                }
                
                Spacer()
                
                Text("\(appSignalCountDTO.signalCount)")
                    .animatableNumber(value: Double(appSignalCountDTO.signalCount), shouldFormatBigNumbers: true)
                    .opacity(displayMode == .signals ? 1.0 : 0.5)
                Text("\(appSignalCountDTO.userCount)")
                    .animatableNumber(value: Double(appSignalCountDTO.userCount), shouldFormatBigNumbers: true)
                    .opacity(displayMode == .users ? 1.0 : 0.5)
            }
        }
    }
}

struct AppAdminDetailView: View {
    let entry: DTO.AppAdminEntry
    
    @EnvironmentObject var api: APIClient
    @State var signalCountHistory: [DTO.InsightData]?
    
    func getSignalCountHistory() {
        api.getAppSignalCountHistory(forAppID: entry.id) {
            signalCountHistory = try? $0.get()
        }
    }

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
            
            Button("Get History") {
                getSignalCountHistory()
            }
            
            if let signalCountHistory = signalCountHistory, let chartData = try? ChartDataSet(data: signalCountHistory) {
                LineChart(data: chartData, shouldCloseShape: false)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .frame(maxWidth: .infinity, maxHeight: 300)
            }
        }
        .padding()
    }
}
