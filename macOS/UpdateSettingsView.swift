//
//  UpdateSettingsView.swift
//  Telemetry Viewer (macOS)
//
//  Created by Daniel Jilg on 16.05.21.
//

import SwiftUI

struct UpdateSettingsView: View {
    @EnvironmentObject var updateService: UpdateService

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Current Version").font(.title)

            Group {
                SettingsKeyView(key: "Your Version", value: updateService.internalVersion)

                SettingsKeyView(key: "Latest Version", value: "\(updateService.latestVersionOnServer?.tag_name ?? "–")")

                if updateService.isUpdateAvailable() {
                    Text("There is an update available. You should download it now.")
                        .foregroundColor(.grayColor)
                } else {
                    Text("You're already on the newest available version of this app. Thank you <3")
                        .foregroundColor(.grayColor)
                }
            }

            Divider()

            Toggle("Include Pre-Releases", isOn: .constant(updateService.includePrereleases))
                .disabled(true)
            Toggle("Include Draft Releases", isOn: .constant(updateService.includeDraftReleases))
                .disabled(true)
            Text("These settings cannot be changed in the current open beta.")
                .font(.footnote)

            Divider()

            if updateService.isUpdateAvailable() {
                if let latestVersion = updateService.latestVersionOnServer, let asset = latestVersion.assets.first {
                    Button("Download Update") {
                        NSWorkspace.shared.open(asset.browser_download_url)
                    }
                }
            } else {
                Button("Check for Update") {
                    updateService.checkForUpdate()
                }
            }

            Spacer()
        }
        .padding()
    }
}

struct UpdateSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateSettingsView()
    }
}
