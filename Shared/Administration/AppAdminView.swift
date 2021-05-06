//
//  OrganizationAdmin.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 07.12.20.
//

import SwiftUI

fileprivate enum DisplayMode: Hashable {
    case users, signals
}

struct AppAdminView: View {
    @EnvironmentObject var api: APIRepresentative
    @State private var isLoading: Bool = false
    @State private var displayMode: DisplayMode = .signals
    
    @State var section1LowerUsers = 100_000.0
    @State var section2LowerUsers = 5000.0
    @State var section1LowerSignals = 10_000_000.0
    @State var section2LowerSignals = 100_000.0

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
                return Double($0.userCount) <= section2LowerUsers
            case .signals:
                return Double($0.signalCount) <= section2LowerSignals
            }
        }
        
        List {
            HStack {
                ValueUnitAndTitleView(value: Double(api.appAdminSignalCounts.count), title: "Active Apps")
                Divider()
                ValueUnitAndTitleView(value: Double(section1.count), title: "Tier 2")
                Divider()
                ValueUnitAndTitleView(value: Double(section2.count), title: "Tier 1")
                Divider()
                ValueUnitAndTitleView(value: Double(section3.count), title: "Free Tier")
            }
            
            Section(header: Text("Variables")) {
                switch displayMode {
                case .users:
                    Slider(value: $section1LowerUsers, in: 0...100_000_000, step: 1000000)
                    Slider(value: $section2LowerUsers, in: 0...10_000, step: 100)
                case .signals:
                    Slider(value: $section1LowerSignals, in: 0...100_000_000, step: 1000000)
                    Slider(value: $section2LowerSignals, in: 0...1_000_000, step: 10000)
                }
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
                Button(action: refreshAppSignalCounts, label: {
                    Image(systemName: "arrow.counterclockwise.circle")
                })
                #endif
            }
        }
        .navigationTitle("App Admin")
        .onAppear { refreshAppSignalCounts() }
        .onReceive(refreshTimer) { _ in refreshAppSignalCounts() }
    }
}


fileprivate struct AddAdminViewListEntry: View {
    let appSignalCountDTO: AppSignalCountDTO
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
