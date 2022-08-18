//
//  UserCountListView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 31.08.20.
//

import SwiftUI

struct UserCountGroupView: View {
    let userCounts: [UserCount]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(userCounts, id: \.self) { userCount in
                    UserCountView(userCount: userCount)
                }
            }
            .padding(.horizontal)
        }
    }
}
