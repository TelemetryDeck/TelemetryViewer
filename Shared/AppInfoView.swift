import SwiftUI

struct AppInfoView: View {
    @EnvironmentObject var api: APIRepresentative

    var body: some View {
        if api.apps.count > 0 {
            Text("Please Select an App")
                .foregroundColor(.grayColor)
        } else {
            VStack(spacing: 20) {
                Text("Welcome to Telemetry!")
                    .font(.title)
                    .foregroundColor(.grayColor)

                Image(systemName: "app.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.grayColor)

                Text("To start, create your first App. You can use that App's unique identifier to send signals from your code.")
                    .foregroundColor(.grayColor)
                VStack {
                    Button("Create First App") {
                        api.create(appNamed: "New App")
                    }
                    .buttonStyle(SmallPrimaryButtonStyle())

                    Button("Documentation: Sending Signals") {
                        #if os(macOS)
                        NSWorkspace.shared.open(URL(string: "https://apptelemetry.io/pages/quickstart.html")!)
                        #else
                        UIApplication.shared.open(URL(string: "https://apptelemetry.io/pages/quickstart.html")!)
                        #endif
                    }
                    .buttonStyle(SmallSecondaryButtonStyle())
                }
            }
            .frame(maxWidth: 400)
        }
    }
}
