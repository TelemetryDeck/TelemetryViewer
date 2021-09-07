//
//  AppUpdater.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 16.12.20.
//

import SwiftUI

class UpateService: ObservableObject {
    @Published var shouldShowUpdateNowScreen: Bool = false
    @Published var latestVersionOnServer: GitHubRelease?

    var includePrereleases: Bool = true
    var includeDraftReleases: Bool = false

    var internalVersion: String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        return "\(appVersion ?? "–")b\(buildNumber ?? "–")"
    }

    struct GitHubReleaseAssets: Codable {
        let id: Int
        let content_type: String
        let size: Int
        let download_count: Int
        let browser_download_url: URL
    }

    struct GitHubRelease: Codable {
        let id: Int
        let name: String
        let tag_name: String
        let body: String
        let draft: Bool
        let prerelease: Bool
        let published_at: Date
        let assets: [GitHubReleaseAssets]
    }
    
    func isUpdateAvailable() -> Bool {
        if let latestVersionOnServer = latestVersionOnServer {
            return latestVersionOnServer.tag_name.compare(internalVersion, options: .numeric) == .orderedDescending
        } else {
            return false
        }
    }
    
    func deferUpdate() {
        shouldShowUpdateNowScreen = false
    }

    func checkForUpdate() {
        let url = URL(string: "https://api.github.com/repos/TelemetryDeck/Viewer/releases")!

        var request = URLRequest(url: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { [unowned self] data, _, _ in
            if let data = data {
                #if DEBUG
                    print("⬅️", data.prettyPrintedJSONString ?? String(data: data, encoding: .utf8) ?? "Undecodable")
                #endif

                if let decoded = try? JSONDecoder.telemetryDecoder.decode([GitHubRelease].self, from: data) {
                    var releases = decoded.sorted(
                        by: { $0.tag_name.compare($1.tag_name, options: .numeric) == .orderedDescending })

                    if !includeDraftReleases { releases = releases.filter { !$0.draft } }
                    if !includePrereleases { releases = releases.filter { !$0.prerelease } }

                    DispatchQueue.main.async {
                        latestVersionOnServer = releases.first

                        if let latestVersionOnServer = latestVersionOnServer {
                            shouldShowUpdateNowScreen = latestVersionOnServer.tag_name.compare(internalVersion, options: .numeric) == .orderedDescending
                        } else {
                            shouldShowUpdateNowScreen = false
                        }
                    }
                } else {
                    print("Failed to decode update data")
                }
            }
        }

        .resume()
    }
}
