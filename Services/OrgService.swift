//
//  OrgService.swift
//  OrgService
//
//  Created by Daniel Jilg on 17.08.21.
//

import Combine
import DataTransferObjects
import Foundation

class OrgService: ObservableObject {
    private let api: APIClient
    private let errorService: ErrorService

    @Published private(set) var loadingState: LoadingState = .idle

    @Published var organization: DTOv2.Organization?

    init(api: APIClient, errors: ErrorService) {
        self.api = api
        self.errorService = errors
    }

    func getOrganisation() {
        self.loadingState = .loading

        Task {
            do {
                let org = try await self.retrieveOrganisation()
                DispatchQueue.main.async {
                    self.organization = org
                    self.loadingState = .finished(Date())
                }
            } catch {
                print(error.localizedDescription)

                if let transferError = error as? TransferError {
                    self.loadingState = .error(transferError.localizedDescription, Date())
                } else {
                    self.loadingState = .error(error.localizedDescription, Date())
                }
            }
        }
    }

    func retrieveOrganisation() async throws -> DTOv2.Organization {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<DTOv2.Organization, Error>) in
            let url = api.urlForPath(apiVersion: .v2, "organization")
            api.get(url) { (result: Result<DTOv2.Organization, TransferError>) in
                switch result {
                case let .success(org):

                    continuation.resume(returning: org)

                case let .failure(error):
                    self.errorService.handle(transferError: error)
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func allOrganizations() async throws -> [OrganizationInfo]{
        let url = api.urlForPath(apiVersion: .v3, "organizations")
        return try await api.get(url: url)
    }
}

