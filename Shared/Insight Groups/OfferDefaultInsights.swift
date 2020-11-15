//
//  OfferDefaultInsights.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 19.10.20.
//

import SwiftUI

struct OfferDefaultInsights: View {
    let app: TelemetryApp
    @EnvironmentObject var api: APIRepresentative
    
    var body: some View {
        VStack(spacing: 20) {
            Text("A New App! Awesome!")
                .font(.largeTitle)
            Text("There are no Insights in this app yet. Insights are pre-defined queries for your signals data that can answer questions like \"How many users are using feature X?\"")
            Text("If you want, Telemetry can create a set of default Insights to get you started. You can always edit or delete these default insights later.")
            Button("Create Default Insights", action: {
                api.createDefaultInsights(for: app)
            })
                .foregroundColor(.accentColor)
                .font(.title2)
                .padding()
                
            Text("To create your own custom Insights, create a new Insight Group and then a new Insight using the buttons in the top right toolbar.")
                .font(.footnote)
            
        }
        .padding()
        .multilineTextAlignment(.center)
        .foregroundColor(.grayColor)
    }
}

struct OfferDefaultInsights_Previews: PreviewProvider {
    static var previews: some View {
        OfferDefaultInsights(app: TelemetryApp(id: UUID(), name: "App", organization: [:]))
            .environmentObject(APIRepresentative())
    }
}
