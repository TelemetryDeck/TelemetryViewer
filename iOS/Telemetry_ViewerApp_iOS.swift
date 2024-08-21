//
//  Telemetry_ViewerApp.swift
//  Shared
//
//  Created by Daniel Jilg on 30.07.20.
//

import RevenueCat
import SwiftUI
import TelemetryClient

@main
struct Telemetry_ViewerApp: App {
    @Environment(\.scenePhase) var scenePhase

    let api: APIClient
    let cacheLayer: CacheLayer
    let errors: ErrorService
    let orgService: OrgService
    let appService: AppService
    let groupService: GroupService
    let insightService: InsightService
    let iconFinderService: IconFinderService
    let signalsService: SignalsService
    let lexiconService: LexiconService
    let queryService: QueryService

    var body: some Scene {
        WindowGroup {
            RootView()
                .onOpenURL(perform: { url in
                    handleIncomingURL(url: url)
                })
                .environmentObject(api)
                .environmentObject(errors)
                .environmentObject(orgService)
                .environmentObject(appService)
                .environmentObject(groupService)
                .environmentObject(insightService)
                .environmentObject(signalsService)
                .environmentObject(lexiconService)
                .environmentObject(iconFinderService)
                .environmentObject(queryService)
        }
        .onChange(of: scenePhase) { newScenePhase in
            if newScenePhase == .active {
                TelemetryDeck.generateNewSession()
            }
        }
    }

    init() {
        self.api = APIClient()
        self.cacheLayer = CacheLayer()
        self.errors = ErrorService()

        self.orgService = OrgService(api: api, errors: errors)
        self.appService = AppService(api: api, errors: errors, orgService: orgService)
        self.groupService = GroupService(api: api, errors: errors)
        self.insightService = InsightService(api: api, errors: errors)

        self.signalsService = SignalsService(api: api)
        self.lexiconService = LexiconService(api: api)

        self.queryService = QueryService(api: api, errors: errors)

        self.iconFinderService = IconFinderService(api: api)

        let configuration = TelemetryManagerConfiguration(appID: "79167A27-EBBF-4012-9974-160624E5D07B")
        TelemetryDeck.initialize(config: configuration)

        UserDefaults.standard.register(defaults: ["isTestingMode": true])

        Purchases.logLevel = .debug
        let randomNumber = Int.random(in: 0 ... 1000)
        Purchases.configure(withAPIKey: "appl_divLZofqLldecaxInylrJZcRPVs", appUserID: "REVENUECAT_USER_DANIEL_\(randomNumber)")
    }

    // telemetryviewer://login/<bearertoken>
    func handleIncomingURL(url: URL) {
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host,
              let path = components.path
        else { return }

        if host == "login" {
            guard let bearerToken = path.split(separator: "/", maxSplits: 1).last else { return }
            api.login(bearerToken: String(bearerToken))
        }
    }
}
