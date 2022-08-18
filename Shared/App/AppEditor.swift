//
//  EditAppView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 10.09.20.
//

import SwiftUI
import TelemetryClient

struct AppEditor: View {
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var iconFinderService: IconFinderService

    let appID: UUID

    @State var appName: String
    @State private var showingAlert = false
    @State private var needsSaving = false

    @State var appIconURL: URL?

    func saveToAPI() {
        appService.update(appID: appID, newName: appName)
    }

    func setNeedsSaving() {
        withAnimation {
            needsSaving = true
        }
    }

    func getIconURL() {
        iconFinderService.findIcon(forAppName: appName) { appIconURL = $0 }
    }

    var padding: CGFloat? {
        #if os(macOS)
        return nil
        #else
        return 0
        #endif
    }

    var body: some View {
        if let app = appService.app(withID: appID) {
            Form {
//                if #available(iOS 15, macOS 12, *) {
//                    appIconURL.map {
//                        AsyncImage(url: $0) { image in
//                            image.resizable()
//                        } placeholder: {
//                            ProgressView()
//                        }
//                        .frame(width: 50, height: 50)
//                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
//                    }
//                }
//
//                Button("Get Icon") {
//                    getIconURL()
//                }

                CustomSection(header: Text("App Name"), summary: EmptyView(), footer: EmptyView()) {
                    TextField("App Name", text: $appName, onEditingChanged: { _ in setNeedsSaving() }) { setNeedsSaving() }

                    if needsSaving {
                        Button("Save") {
                            saveToAPI()
                        }
                    }
                }

                CustomSection(header: Text("Unique Identifier"), summary: EmptyView(), footer: EmptyView()) {
                    VStack(alignment: .leading) {
                        Button(app.id.uuidString) {
                            saveToClipBoard(app.id.uuidString)
                        }
                        .buttonStyle(SmallPrimaryButtonStyle())
                        #if os(macOS)
                        Text("Click to copy this UUID into your apps for tracking.").font(.footnote)
                        #else
                        Text("Tap to copy this UUID into your apps for tracking.").font(.footnote)
                        #endif
                    }
                }

                CustomSection(header: Text("Delete"), summary: EmptyView(), footer: EmptyView()) {
                    Button("Delete App \"\(app.name)\"") {
                        showingAlert = true
                    }
                    .buttonStyle(SmallSecondaryButtonStyle())
                    .accentColor(.red)
                }

                #if os(macOS)
                Spacer()
                #endif
            }
            .padding(.horizontal, self.padding)
            .padding(.vertical, self.padding)
            .navigationTitle("App Settings")
            .onDisappear { saveToAPI() }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Are you sure you want to delete \(app.name)?"),
                    message: Text("This will delete the app, all insights, and all received Signals for this app. There is no undo."),
                    primaryButton: .destructive(Text("Delete")) {
                        appService.delete(appID: appID)
                    },
                    secondaryButton: .cancel()
                )
            }

        } else {
            Text("No App Selected")
        }
    }
}

// struct AppEditor_Previews: PreviewProvider {
//    static var previews: some View {
//        AppEditor(appID: UUID.empty, appName: "test")
//            .environmentObject(AppService(api: APIClient(), errors: ErrorService(), orgService: OrgService()))
//    }
// }
