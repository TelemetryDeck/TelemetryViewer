//
//  CardView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 02.09.20.
//

import SwiftUI

struct MacNavigationView<Content>: View where Content: View {
    private let content: Content
    private let title: String
    private let backButtonAction: (() -> Void)?
    private let backButtonTitle: String
    private let height: CGFloat

    public init(title: String, backButtonAction: (() -> Void)? = nil, backButtonTitle: String = "Back", height: CGFloat = 500, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.title = title
        self.backButtonAction = backButtonAction
        self.backButtonTitle = backButtonTitle
        self.height = height
    }

    var body: some View {
        VStack(alignment: .leading) {
            if let backButtonAction = backButtonAction {
                Button(action: backButtonAction, label: {
                    HStack(spacing: 1) {
                        Image(systemName: "chevron.backward")
                        Text(backButtonTitle)
                    }
                })
                    .buttonStyle(BackButtonStyle())
            }

            Text(title)
                .font(.title)
                .padding(.bottom)

            content
        }
        .padding()
        .frame(minHeight: height)
    }
}
