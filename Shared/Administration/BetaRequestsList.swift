//
//  BetaRequestsList.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.10.20.
//

import SwiftUI

struct BetaRequestsList: View {
    @EnvironmentObject var api: APIRepresentative

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    func listItemView(for betaRequest: BetaRequestEmail) -> some View {
        ListItemView {
            Button(betaRequest.registrationToken) {
                saveToClipBoard(betaRequest.registrationToken)
            }
            
            Button(betaRequest.email) {
                saveToClipBoard(betaRequest.email)
            }
            
            Spacer()
            VStack(alignment: .trailing) {
                Text(dateFormatter.string(from: betaRequest.requestedAt))
                Text(betaRequest.isFulfilled ? "Fulfilled" : "Unfulfilled")
            }
            .foregroundColor(.grayColor)
        }
    }
    
    var body: some View {
        ScrollView {
            Section(header: Text("Unfulfilled")) {
                ForEach(api.betaRequests.filter({ !$0.isFulfilled })) { betaRequest in
                    listItemView(for: betaRequest)
                }
            }
            
            Section(header: Text("Fulfilled")) {
                ForEach(api.betaRequests.filter({ $0.isFulfilled })) { betaRequest in
                    listItemView(for: betaRequest)
                }
            }
            
            
        }
        .padding(.horizontal)
        .navigationTitle("Beta Requests")
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
