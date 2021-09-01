//
//  FeedbackView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 13.04.21.
//

import SwiftUI

struct FeedbackViewEntry: View {
    let title: String
    let subtitle: String
    let link: String
    let systemImage: String
    
    var body: some View {
        Button(action: {
            URL(string: link)?.open()
        }, label: {
            HStack {
                VStack(alignment: .leading) {
                    Label(title, systemImage: systemImage)
                        .font(.title2)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.grayColor)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right").foregroundColor(.grayColor)
            }
            .padding()
            
            #if os(macOS)
            Divider()
            #endif
        })
        .buttonStyle(CardButtonStyle(isSelected: false))
    }
}

struct FeedbackView: View {
    var body: some View {
        List {
            FeedbackViewEntry(
                title: "Documentation",
                subtitle: "All documentation articles available for AppTelemetry and its clients",
                link: "https://telemetrydeck.com/pages/docs.html",
                systemImage: "text.book.closed"
            )
            
            FeedbackViewEntry(
                title: "Swift Client",
                subtitle: "The AppTelemetry Swift Client for inclusion in your apps",
                link: "https://github.com/AppTelemetry/SwiftClient",
                systemImage: "cloud"
            )
            
            FeedbackViewEntry(
                title: "GitHub Issues",
                subtitle: "Create new tickets for features you'd like or bugs you found, or discuss existing tickets.",
                link: "https://github.com/AppTelemetry/Viewer/issues",
                systemImage: "ladybug"
            )
            
            FeedbackViewEntry(
                title: "GitHub Discussions",
                subtitle: "Ask and discuss questions regarding the app, the client, future development, etc.",
                link: "https://github.com/AppTelemetry/Viewer/discussions",
                systemImage: "bubble.left.and.bubble.right"
            )
            
            FeedbackViewEntry(
                title: "Slack Workspace",
                subtitle: "If you prefer real-time conversation, AppTelemetry also has a Slack, come in and let's talk",
                link: "https://telemetrydeck.com/pages/slack.html",
                systemImage: "quote.bubble"
            )
        }
        .navigationTitle("Help & Feedback")
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FeedbackView()
        }
    }
}
