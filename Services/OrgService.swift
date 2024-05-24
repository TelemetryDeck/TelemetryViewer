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

    // Wasn't getting called before -> Never leaving loading state.
    // For now called when retrieveOrganisations also called
    // Maybe move getCode into the retrieve Func?
    func getOrganisation() {
        let locallyCachedOrganization = retrieveFromDisk()
        self.organization = locallyCachedOrganization

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

                    self.saveToDisk(org: org)

                    continuation.resume(returning: org)

                case let .failure(error):
                    self.errorService.handle(transferError: error)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

/// this is interesting, do we want this for more than the org?
private extension OrgService {
    var organizationCacheFilePath: URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let cachesDirectoryUrl = urls[0]
        let fileUrl = cachesDirectoryUrl.appendingPathComponent("telemetrydeck.organization.json")
        let filePath = fileUrl.path

        if !fileManager.fileExists(atPath: filePath) {
            let contents = Data()
            fileManager.createFile(atPath: filePath, contents: contents)
        }

        return fileUrl
    }

    func saveToDisk(org: DTOv2.Organization) {
        guard let data = try? JSONEncoder.telemetryEncoder.encode(org) else { return }
        try? data.write(to: self.organizationCacheFilePath, options: .atomic)
    }

    func retrieveFromDisk() -> DTOv2.Organization? {
        guard let data = try? Data(contentsOf: organizationCacheFilePath) else { return nil }
        return try? JSONDecoder.telemetryDecoder.decode(DTOv2.Organization.self, from: data)
    }
}
