//
//  AskForMarketingEmailsView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 16.05.21.
//

import SwiftUI
import TelemetryDeckClient

struct AskForMarketingEmailsView: View {
    @EnvironmentObject var api: APIClient
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Hi, quick question!")
                    .font(.title)
                
                Text("There will be a free ") + Text("TelemetryDeck newsletter").bold() + Text(" soon with contents like:")
                
                Label("Tips on how to generate good data with signals", systemImage: "wand.and.stars")
                Label("News, new features and best practices regarding TelemetryDeck", systemImage: "flowchart")
                Label("Articles about TelemetryDeck's features and how to get the most out of them", systemImage: "chart.pie.fill")
                Label("Tutorials on how to improve your revenue and engagement without resorting to dark patterns", systemImage: "chart.bar.xaxis")
                
                Text("Do you want the newsletter? It's free, low-volume, and you can unsubscribe at any time in the app settings.")
                
                Button("Send me the Newletter") {
                    guard let user = api.user else { return }
                    var userDTO = user
                    userDTO.receiveMarketingEmails = true
                    api.updateUser(with: userDTO)
                    api.needsDecisionForMarketingEmails = false
                    
                }
                    .buttonStyle(PrimaryButtonStyle())
                
                Button("Don't send me the Newsletter") {
                        guard let user = api.user else { return }
                        var userDTO = user
                        userDTO.receiveMarketingEmails = false
                        api.updateUser(with: userDTO)
                        api.needsDecisionForMarketingEmails = false
                }
                    .buttonStyle(SecondaryButtonStyle())
                
                Group {
                    Text("If you change your mind, go to the app settings to switch the newsletter on or off.")
                        .font(.footnote)
                        .foregroundColor(.grayColor)
                
                    Text("And this is the only time I'm bothering you about this, promise!")
                        .font(.footnote)
                        .foregroundColor(.grayColor)
                }
            }
            .frame(maxWidth: 400, minHeight: 500)
            .fixedSize(horizontal: false, vertical: true)
            .padding()
        }
    }
}

struct AskForMarketingEmailsView_Previews: PreviewProvider {
    static var previews: some View {
        AskForMarketingEmailsView()
    }
}
