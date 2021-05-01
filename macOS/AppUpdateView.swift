//
//  AppUpdateView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 16.12.20.
//

import SwiftUI
import TelemetryClient

struct AppUpdateView: View {
    @EnvironmentObject var appUpdater: AppUpdater
    let byteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Current Version").font(.title)

                Text("Telemetry Viewer Version: ") +
                    Text(appUpdater.internalVersion).font(.headline)

                Text("Latest Version on Server: ") +
                    Text("\(appUpdater.latestVersionOnServer?.tag_name ?? "–")").font(.headline)

                Text("\(appUpdater.isAppUpdateAvailable ? "There is an update available for your version of Telemetry Viewer" : "You're using the latest version")")
                    .padding(.top)

                Divider()

                if appUpdater.isAppUpdateAvailable, let latestVersion = appUpdater.latestVersionOnServer {
                    Text("Latest Version").font(.title)

                    CardView {
                        VStack(alignment: .leading) {
                            HStack(alignment: .lastTextBaseline) {
                                Text(latestVersion.name).font(.largeTitle)
                                Spacer()
                                Text(latestVersion.tag_name).foregroundColor(.grayColor)
                            }
                            Divider().padding(.bottom)
                            Text(latestVersion.body)
                                .fixedSize(horizontal: false, vertical: true)

                            if let asset = latestVersion.assets.first {
                                Button("Download \(byteCountFormatter.string(fromByteCount: Int64(asset.size)))") {
                                    NSWorkspace.shared.open(asset.browser_download_url)
                                    TelemetryManager.send("UpdateScreenDownloadUpdate")
                                }
                                .buttonStyle(PrimaryButtonStyle())
                            }
                        }
                        .padding()
                    }
                } else {
                    Button("Check for Update") {
                        appUpdater.checkForUpdate()
                        TelemetryManager.send("UpdateScreenManualCheckForUpdate")
                    }
                    .buttonStyle(SmallSecondaryButtonStyle())
                }
            }
            .padding()
        }
        .onAppear {
            TelemetryManager.send("UpdateScreenOpened")
        }
    }
}

struct AppUpdateView_Previews: PreviewProvider {
    static var previews: some View {
        let customAppUpdater = AppUpdater()
        customAppUpdater.isAppUpdateAvailable = false
        customAppUpdater.latestVersionOnServer = AppUpdater.GitHubRelease(id: 3, name: "1b27", tag_name: "1b27", body: "hello world lorem ipsum", draft: false, prerelease: false, published_at: Date(), assets: [AppUpdater.GitHubReleaseAssets(id: 4, content_type: "application/zip", size: 928_158, download_count: 345, browser_download_url: URL(string: "https://github.com/AppTelemetry/Viewer/releases/download/1b14/TelemetryViewer-1b14.zip")!)])
        return AppUpdateView().environmentObject(customAppUpdater)
    }
}
