//
//  StatusMessageDisplay.swift
//  StatusMessageDisplay
//
//  Created by Daniel Jilg on 17.09.21.
//

import SwiftUI
import DataTransferObjects

struct StatusMessageDisplay: View {
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var errorService: ErrorService

    @AppStorage("dismissedNotificationsIDs4") var _dismissedNotificationsIDs: String = ""

    var dismissedNotificationsIDs: [String] {
        let x = _dismissedNotificationsIDs.split(separator: ",")
        return x.map { String($0) }
    }

    @State var statusMessages: [DTOv2.StatusMessage] = []

    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            ForEach(statusMessages) { message in
                if !dismissedNotificationsIDs.contains(message.id) {
                    StatusMessageBanner(statusMessage: message)
                        .onTapGesture {
                            dismissNotification(id: message.id)
                        }
                }
            }
        }
        .onAppear(perform: loadMessages)
        .onReceive(timer) { _ in
            loadMessages()
        }
    }

    func dismissNotification(id: String) {
        if dismissedNotificationsIDs.count > 20 {
            let dismissedNotificationsIDsCopy = dismissedNotificationsIDs.suffix(20)
            _dismissedNotificationsIDs = dismissedNotificationsIDsCopy.joined(separator: ",")
            _dismissedNotificationsIDs.append(",")
        }
        _dismissedNotificationsIDs.append(id + ",")
    }

    func loadMessages() {
        statusMessages = []
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
        api.get(url) { (result: Result<[DTOv2.StatusMessage], TransferError>) in
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
