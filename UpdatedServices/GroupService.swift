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

    private let loadingState = Cache<DTOv2.Group.ID, LoadingState>()

    var loadingCancellable: AnyCancellable?

    @Published var groupsDictionary = [DTOv2.Group.ID: DTOv2.Group]()

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

    func group(withID groupID: DTOv2.Group.ID) -> DTOv2.Group? {
        return groupsDictionary[groupID]
    }

    func retrieveGroup(with groupID: DTOv2.Group.ID) {
        performRetrieval(ofGroupWithID: groupID)
    }

    func create(insightGroupNamed: String, for appID: UUID, callback: ((Result<DTOv1.InsightGroup, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups")

        api.post(["title": insightGroupNamed], to: url) { (result: Result<DTOv1.InsightGroup, TransferError>) in
            callback?(result)
        }
    }

    func update(insightGroup: DTOv1.InsightGroup, in appID: UUID, callback: ((Result<DTOv1.InsightGroup, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups", insightGroup.id.uuidString)

        api.patch(insightGroup, to: url) { (result: Result<DTOv1.InsightGroup, TransferError>) in
            callback?(result)
        }
    }

    func delete(insightGroupID: UUID, in appID: UUID, callback: ((Result<DTOv1.InsightGroup, TransferError>) -> Void)? = nil) {
        let url = api.urlForPath("apps", appID.uuidString, "insightgroups", insightGroupID.uuidString)

        api.delete(url) { (result: Result<DTOv1.InsightGroup, TransferError>) in
            // TODO:
            callback?(result)
        }
        groupsDictionary = groupsDictionary.filter() { $0.key != insightGroupID }
    }
}

private extension GroupService {
    func performRetrieval(ofGroupWithID groupID: DTOv2.Group.ID) {
        switch loadingState(for: groupID) {
        case .loading, .error:
            return
        default:
            break
        }

        loadingState[groupID] = .loading

        let url = api.urlForPath(apiVersion: .v2, "groups", groupID.uuidString)

        api.get(url) { [weak self] (result: Result<DTOv2.Group, TransferError>) in

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
