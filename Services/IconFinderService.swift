//
//  IconFinder.swift
//  IconFinder
//
//  Created by Daniel Jilg on 22.09.21.
//

import Foundation
import DataTransferObjects

struct ItunesSearchResult: Codable {
    let screenshotUrls: [URL]
    let artworkUrl512: URL
    let description: String
    let sellerName: String
    let trackName: String
}

struct ItunesSearchResultGroup: Codable {
    let resultCount: Int
    let results: [ItunesSearchResult]
}

class IconFinderService: ObservableObject {

    let api: APIClient

    init(api: APIClient) {
        self.api = api
    }

    func findIcon(forAppName appName: String, completion: @escaping (URL?) -> Void) {
        let searchString = appName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? appName
        let urlTemplate = "http://itunes.apple.com/search?term=\(searchString)&entity=software"

        guard let url = URL(string: urlTemplate) else { return }

        let defaultV = ItunesSearchResultGroup.init(resultCount: 0, results: [])

        api.get(url, defaultValue: defaultV) { (result: Result<ItunesSearchResultGroup, TransferError>) in
            switch result {
            case .success(let resultGroup):
                completion(resultGroup.results.first?.artworkUrl512)
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }
}
