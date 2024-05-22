//
//  InsightGroupService.swift
//  InsightGroupService
//
//  Created by Daniel Jilg on 17.08.21.
//

import Combine
import DataTransferObjects
import Foundation

class GroupService: ObservableObject {
    private let api: APIClient
    private let errorService: ErrorService

    private let loadingState = Cache<InsightGroupInfo.ID, LoadingState>()

    var loadingCancellable: AnyCancellable?

    @Published var groupsDictionary = [InsightGroupInfo.ID: InsightGroupInfo]()

    init(api: APIClient, errors: ErrorService) {
        self.api = api
        errorService = errors

        loadingCancellable = loadingState.objectWillChange.receive(on: DispatchQueue.main).sink { [weak self] in self?.objectWillChange.send() }
    }

    func loadingState(for groupID: DTOv2.Group.ID) -> LoadingState {
        let loadingState = loadingState[groupID] ?? .idle

        // after 60 seconds, clear the error, allowing another load
        switch loadingState {
        case let .error(_, date):
            if date < Date() - 60 {
                self.loadingState[groupID] = .idle
                return .idle
            }
        default:
            break
        }

        return loadingState
    }

    func group(withID groupID: InsightGroupInfo.ID) -> InsightGroupInfo? {
        return groupsDictionary[groupID]
    }

    func retrieveGroup(with groupID: InsightGroupInfo.ID) {
        performRetrieval(ofGroupWithID: groupID)
    }

    func create(insightGroupNamed: String, for appID: UUID, callback: ((Result<InsightGroupInfo, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath(apiVersion: .v3, "groups")

        api.post(["title": insightGroupNamed, "appID": appID.uuidString], to: url) { (result: Result<InsightGroupInfo, TransferError>) in
            callback?(result)
        }
    }

    func update(insightGroup: InsightGroupInfo, in appID: UUID, callback: ((Result<InsightGroupInfo, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath(apiVersion: .v3, "groups", insightGroup.id.uuidString)

        api.patch(insightGroup, to: url) { (result: Result<InsightGroupInfo, TransferError>) in
            callback?(result)
        }
    }

    func delete(insightGroupID: UUID, in appID: UUID, callback: ((Result<[String: String], TransferError>) -> Void)? = nil) {
        let url = api.urlForPath(apiVersion: .v2, "groups", insightGroupID.uuidString)

        api.delete(url) { (result: Result<[String: String], TransferError>) in
            callback?(result)
        }
        groupsDictionary = groupsDictionary.filter { $0.key != insightGroupID }
    }
}

private extension GroupService {
    func performRetrieval(ofGroupWithID groupID: InsightGroupInfo.ID) {
        switch loadingState(for: groupID) {
        case .loading, .error:
            return
        default:
            break
        }

        loadingState[groupID] = .loading

        let url = api.urlForPath(apiVersion: .v3, "groups", groupID.uuidString)

        api.get(url) { [weak self] (result: Result<InsightGroupInfo, TransferError>) in

            switch result {
            case let .success(group):
                DispatchQueue.main.async {
                    self?.groupsDictionary[groupID] = group
                    self?.loadingState[groupID] = .finished(Date())
                }

            case let .failure(error):
                self?.errorService.handle(transferError: error)
                self?.loadingState[groupID] = .error(error.localizedDescription, Date())
            }
        }
    }
}
