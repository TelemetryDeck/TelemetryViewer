//
//  AppUpdater.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 16.12.20.
//

import SwiftUI

class AppUpdater: ObservableObject {
    @Published var isAppUpdateAvailable: Bool = false
    @Published var latestVersionOnServer: GitHubRelease?

    var getBetas: Bool = false

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

    func checkForUpdate() {
        let url = URL(string: "https://api.github.com/repos/AppTelemetry/Viewer/releases")!

        var request = URLRequest(url: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                #if DEBUG
                print("⬅️", data.prettyPrintedJSONString ?? String(data: data, encoding: .utf8) ?? "Undecodable")
                #endif

                if let decoded = try? JSONDecoder.telemetryDecoder.decode([GitHubRelease].self, from: data) {
                    print(decoded)
                    DispatchQueue.main.async {
                        if self.getBetas {
                            self.latestVersionOnServer = decoded.first(where: { !$0.draft })
                        } else {
                            self.latestVersionOnServer = decoded.first(where: { !$0.prerelease && !$0.draft })
                        }

                        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

                        self.isAppUpdateAvailable = (self.latestVersionOnServer?.tag_name ?? "") > appVersion ?? ""
                    }
                } else {
                    print("Failed to decode update data")
                }
            }
        }

        .resume()
    }
}
