//
//  StatusMessageDisplay.swift
//  StatusMessageDisplay
//
//  Created by Daniel Jilg on 17.09.21.
//

import SwiftUI

struct StatusMessageDisplay: View {
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var errorService: ErrorService

    @State var statusMessages: [DTOsWithIdentifiers.StatusMessage] = []

    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 1) {
            ForEach(statusMessages) { message in
                StatusMessage(statusMessage: message)
            }
        }
        .background(Color.cardBackground)
        .onAppear(perform: loadMessages)
        .onReceive(timer) { _ in
            loadMessages()
        }
    }

    func loadMessages() {
        loadOrganizationStatusMessages()
        loadPublicStatusMessages()
    }

    func loadPublicStatusMessages() {
        let url = api.urlForPath(apiVersion: .v2, "status", "public-messages")
        load(url: url)
    }

    func loadOrganizationStatusMessages() {
        let url = api.urlForPath(apiVersion: .v2, "status", "organization-messages")
        load(url: url)
    }

    func load(url: URL) {
        api.get(url) { (result: Result<[DTOsWithIdentifiers.StatusMessage], TransferError>) in
            switch result {
            case let .success(msgs):
                DispatchQueue.main.async {
                    statusMessages.append(contentsOf: msgs)
                }

            case let .failure(error):
                self.errorService.handle(transferError: error)
            }
        }
    }
}
