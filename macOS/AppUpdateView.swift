//
//  AppUpdateView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 16.12.20.
//

import SwiftUI
import TelemetryClient

struct AppUpdateView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AppUpdateViewTop()
            ReleaseNotesView()
            AppUpdateViewDownloadButton()
        }
        .padding()
        .frame(maxWidth: 400)
        .onAppear {}
    }
}

struct AppUpdateView_Previews: PreviewProvider {
    static var previews: some View {
        let customAppUpdater = UpdateService()
        customAppUpdater.shouldShowUpdateNowScreen = false
        customAppUpdater.latestVersionOnServer = UpdateService.GitHubRelease(
            id: 3,
            name: "1.0.0b1227",
            tag_name: "1.0.0b1227",
            body: "hello world lorem ipsum",
            draft: false,
            prerelease: false,
            published_at: Date(),
            assets: [
                UpdateService.GitHubReleaseAssets(
                    id: 4,
                    content_type: "application/zip",
                    size: 928_158,
                    download_count: 345,
                    browser_download_url: URL(
                        string: "https://github.com/TelemetryDeck/Viewer/releases/download/1b14/TelemetryViewer-1b14.zip"
                    )!
                )
            ]
        )
        return AppUpdateView().environmentObject(customAppUpdater)
    }
}

struct AppUpdateViewTop: View {
    @EnvironmentObject var updateService: UpdateService

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("App Update Available")
                .font(.title)

            Text("A new version of TelemetryDeck Viewer is available (\(updateService.latestVersionOnServer?.tag_name ?? "–")). Please download it now.")
                .foregroundColor(.grayColor)

            Text("After downloading, you should move the app into your Applications folder, replacing the old version of the app.")
                .font(.footnote)
                .foregroundColor(.grayColor)
        }
    }
}

struct ReleaseNotesView: View {
    @EnvironmentObject var updateService: UpdateService

    var body: some View {
        if let latestVersion = updateService.latestVersionOnServer {
            CardView {
                ScrollView {
                    Text(latestVersion.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
            }
            // intentionally croooked to make scrollability obvious
            .frame(idealHeight: 327)
        }
    }
}

struct AppUpdateViewDownloadButton: View {
    @EnvironmentObject var updateService: UpdateService

    let byteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter
    }()

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            if let latestVersion = updateService.latestVersionOnServer, let asset = latestVersion.assets.first {
                Button("Download \(byteCountFormatter.string(fromByteCount: Int64(asset.size)))") {
                    NSWorkspace.shared.open(asset.browser_download_url)
                }
                .buttonStyle(PrimaryButtonStyle())
            }

            Button(action: {
                updateService.deferUpdate()
            }, label: {
                Text("Not Now (You can update by opening the app settings)")
            })
            .buttonStyle(BackButtonStyle())
        }
    }
}
