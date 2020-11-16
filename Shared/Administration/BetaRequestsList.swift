//
//  BetaRequestsList.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.10.20.
//

import SwiftUI



struct BetaRequestDetailView: View {
    var betaRequestID: UUID?
    @EnvironmentObject var api: APIRepresentative
    
    var body: some View {
        VStack(alignment: .leading) {
            if let betaRequest = api.betaRequests.first { $0.id == betaRequestID } {
            
            Text(betaRequest.email).font(.title2)
            
                LazyVGrid(columns: [GridItem(.flexible(maximum: 150)), GridItem(.flexible())], alignment: .leading) {
                    Text("Email").padding(3)
                    Button(betaRequest.email) {
                        saveToClipBoard(betaRequest.email)
                    }
                    .buttonStyle(SmallSecondaryButtonStyle())
                    
                    Text("Registration Token").padding(3)
                    Button(betaRequest.registrationToken) {
                        saveToClipBoard(betaRequest.registrationToken)
                    }
                    .buttonStyle(SmallSecondaryButtonStyle())
                    
                    Text("Requested At").padding(3)
                    
                    Text(betaRequest.requestedAt, style: .date) + Text(" at ") + Text(betaRequest.requestedAt, style: .time)
                    
                    Text("Email Sent at").padding(3)
                    if let sentAt = betaRequest.sentAt {
                        Text(sentAt, style: .date) + Text(" at ") + Text(sentAt, style: .time)
                    } else {
                        Text("–")
                    }
                    
                    Text("Fulfilled").padding(3)
                    Text(betaRequest.isFulfilled ? "Yes" : "No")
                }
                
                
                
                if betaRequest.sentAt == nil {
                    Divider()
                    Button("Send Email Now") {
                        api.sendEmail(for: betaRequest)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                
                Divider()
                
                Button("Mark as \(betaRequest.isFulfilled ? "Not Fulfilled" : "Fulfilled")") {
                    let updateBody = BetaRequestUpdateBody(sentAt: betaRequest.sentAt, isFulfilled: !betaRequest.isFulfilled)
                    api.update(betaRequest: betaRequest, with: updateBody)
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("Delete this Request") {
                    api.delete(betaRequest: betaRequest)
                }
                .buttonStyle(SecondaryButtonStyle())
                
                
                Spacer()
            
            } else {
                Text("This Item does no longer exist.")
                    .foregroundColor(.grayColor)
            }
        }
        .navigationTitle(api.betaRequests.first { $0.id == betaRequestID }?.email ?? "No Selection")
        .padding(.horizontal)
    }
}

struct BetaRequestsList: View {
    @EnvironmentObject var api: APIRepresentative
    @State private var selectedItem: BetaRequestEmail?
    
    let refreshTimer = Timer.publish(
        every: 1 * 60, // 1 minute
        on: .main,
        in: .common
    ).autoconnect()
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var sizeClass
    #else
    enum SizeClassNoop {
        case compact
        case notCompact
    }
    
    var sizeClass: SizeClassNoop = .notCompact
    #endif
    
    func listItemView(for betaRequest: BetaRequestEmail) -> some View {
        Group {
            #if os(iOS)
            if sizeClass == .compact {
                NavigationLink(destination: BetaRequestDetailView(betaRequestID: betaRequest.id)) {
                    Text(betaRequest.email)
                }
            } else {
                ListItemView(background: betaRequest == selectedItem ? Color.accentColor : Color.grayColor.opacity(0.2)) {
                    Text(betaRequest.email)
                    Spacer()
                    Text(betaRequest.requestedAt, style: .date)
                    Text(betaRequest.requestedAt, style: .time)
                }.onTapGesture {
                    selectedItem = betaRequest
                }
            }
            #else
            ListItemView(background: betaRequest == selectedItem ? Color.accentColor : Color.grayColor.opacity(0.2)) {
                Text(betaRequest.email)
                Spacer()
                Text(betaRequest.requestedAt, style: .date)
                Text(betaRequest.requestedAt, style: .time)
            }.onTapGesture {
                selectedItem = betaRequest
            }
            #endif
        }
    }
    
    var body: some View {
        HStack {
            List {
                let unfulfilled = api.betaRequests.filter({ !$0.isFulfilled && $0.sentAt == nil })
                let emailSent = api.betaRequests.filter({ !$0.isFulfilled && $0.sentAt != nil })
                let fulfilled = api.betaRequests.filter({ $0.isFulfilled })
                
                Section(header: Text("Unfulfilled (\(unfulfilled.count))")) {
                    ForEach(unfulfilled) { betaRequest in
                        listItemView(for: betaRequest)
                    }
                }
                Section(header: Text("Email Sent (\(emailSent.count))")) {
                    ForEach(emailSent) { betaRequest in
                        listItemView(for: betaRequest)
                    }
                }
                
                Section(header: Text("Fulfilled (\(fulfilled.count))")) {
                    ForEach(fulfilled) { betaRequest in
                        listItemView(for: betaRequest)
                    }
                }
            }
            
            if selectedItem != nil {
                HStack {
                    Divider()
                    BetaRequestDetailView(betaRequestID: selectedItem?.id)
                }
                .frame(maxWidth: 400)
            }
        }
        .navigationTitle("Beta Requests")
        .onAppear() {
            api.getBetaRequests()
        }
        .onReceive(refreshTimer) { _ in
            api.getBetaRequests()
        }
    }
}

struct BetaRequestsList_Previews: PreviewProvider {
    static var previews: some View {
        BetaRequestsList().environmentObject(APIRepresentative())
    }
}
