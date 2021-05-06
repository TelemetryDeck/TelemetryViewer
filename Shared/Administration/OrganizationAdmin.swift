//
//  OrganizationAdmin.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 07.12.20.
//

import SwiftUI

struct OrganizationAdmin: View {
    @EnvironmentObject var api: APIRepresentative
    @State private var selectedOrganization: OrganizationAdminListEntry?
    @State private var sidebarShown: Bool = false
    @State private var isLoading: Bool = false

    let refreshTimer = Timer.publish(
        every: 1 * 60, // 1 minute
        on: .main,
        in: .common
    ).autoconnect()

    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return formatter
    }()

    var padding: CGFloat? {
        #if os(macOS)
            return nil
        #else
            return 0
        #endif
    }

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

    var body: some View {
        AdaptiveStack(spacing: 0) {
            List {
                if isLoading {
                    ProgressView()
                }

                ForEach(api.organizationAdminListEntries) { entry in
                    ListItemView(selected: selectedOrganization?.id == entry.id, background: entry.isSuperOrg ?Color.telemetryOrange.opacity(0.2) : Color.grayColor.opacity(0.2)) {
                        Text(entry.name)
                        Spacer()
                        Text(numberFormatter.string(from: NSNumber(value: entry.sumSignals))!)
                    }
                    .onTapGesture {
                        selectedOrganization = entry
                        withAnimation {
                            sidebarShown = true
                        }
                    }
                }
            }

            if sidebarShown {
                if let entry = selectedOrganization {
                    DetailSidebar(isOpen: $sidebarShown, maxWidth: DefaultSidebarWidth) {
                        VStack {
                            ScrollView {
                                CustomSection(header: Text("Org"), summary: Text(entry.name), footer: EmptyView()) {
                                    Text(entry.name)
                                    Text(entry.foundedAt, style: .date)
                                    Text("Super Org: \(entry.isSuperOrg ? "YES" : "NO")")
                                }

                                let numberOfSignals = numberFormatter.string(from: NSNumber(value: entry.sumSignals))!
                                CustomSection(header: Text("Signals This Month"), summary: EmptyView(), footer: EmptyView()) {
                                    Text(numberOfSignals)
                                }

                                CustomSection(header: Text("Founding User"), summary: EmptyView(), footer: EmptyView()) {
                                    Text("\(entry.firstName ?? "–") \(entry.lastName ?? "–")")

                                    Button(entry.email) {
                                        saveToClipBoard(entry.email)
                                    }
                                    .buttonStyle(SmallSecondaryButtonStyle())
                                }
                            }
                        }
                        .padding(.horizontal, padding)
                    }

                    .transition(DefaultMoveTransition)
                }
            }
        }
        .navigationTitle("Organization Admin")
        .onAppear {
            isLoading = true
            api.getOrganizationAdminEntries { _ in
                self.isLoading = false
            }
        }
        .onReceive(refreshTimer) { _ in
            api.getOrganizationAdminEntries()
        }
    }
}
