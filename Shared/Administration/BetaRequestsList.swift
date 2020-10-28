//
//  BetaRequestsList.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.10.20.
//

import SwiftUI

struct BetaRequestsList: View {
    @EnvironmentObject var api: APIRepresentative
    
    private let dateFormatter: DateFormatter = DateFormatter()
    
    var body: some View {
        List {
            ForEach(api.betaRequests) { betaRequest in
                HStack {

                    Text(betaRequest.email)
                    Text(dateFormatter.string(from: betaRequest.requestedAt))
                    Text(betaRequest.isFulfilled ? "Fulfilled" : "Unfulfilled")
                }
            }
        }
        .onAppear() {
            api.getBetaRequests()
        }
    }
}

struct BetaRequestsList_Previews: PreviewProvider {
    static var previews: some View {
        BetaRequestsList().environmentObject(APIRepresentative())
    }
}
