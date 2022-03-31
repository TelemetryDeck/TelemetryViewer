//
//  IntentHandler.swift
//  TelemetryDeckIntents
//
//  Created by Charlotte Böhm on 05.10.21.
//

import Intents
import TelemetryClient
import DataTransferObjects

class IntentHandler: INExtension, ConfigurationIntentHandling {
    let api: APIClient
    let cacheLayer: CacheLayer
    let errors: ErrorService
    let insightService: InsightService

    override init() {
        let configuration = TelemetryManagerConfiguration(appID: "79167A27-EBBF-4012-9974-160624E5D07B")
        TelemetryManager.initialize(with: configuration)

        self.api = APIClient()
        self.cacheLayer = CacheLayer()
        self.errors = ErrorService()

        self.insightService = InsightService(api: api, errors: errors)

        super.init()
    }

    func provideInsightOptionsCollection(for intent: ConfigurationIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<InsightIDSelection>?, Error?) -> Void) {
        insightService.widgetableInsights { apps in
            
            let sortedApps = apps.sorted {
                $0.name < $1.name
            }
            
            if searchTerm == nil {
                let appSections: [INObjectSection<InsightIDSelection>] = sortedApps.map { app in
                    let appSection = INObjectSection(title: app.name, items: app.insights.sorted(by: { $0.title < $1.title }).map { insight -> InsightIDSelection in
                        let selectedInsight = InsightIDSelection(identifier: insight.id.uuidString, display: insight.title, subtitle: insight.displayMode.rawValue.uppercased(), image: nil)
                        selectedInsight.appName = app.name
                        return selectedInsight
                    })
                    return appSection
                }

                let collection = INObjectCollection(sections: appSections)
                completion(collection, nil)
            } else {
                var appSections: [INObjectSection<InsightIDSelection>] = []
                sortedApps.forEach { app in
                    var filteredInsights: [InsightIDSelection] = []
                    app.insights.sorted(by: { $0.title < $1.title }).forEach { insight in
                        if insight.title.lowercased().contains(searchTerm!.lowercased()) || app.name.lowercased().contains(searchTerm!.lowercased()) || insight.displayMode.rawValue.lowercased().contains(searchTerm!.lowercased()) {
                            let filteredInsight = InsightIDSelection(identifier: insight.id.uuidString, display: insight.title, subtitle: insight.displayMode.rawValue.uppercased(), image: nil)
                            filteredInsight.appName = app.name
                            filteredInsights.append(filteredInsight)
                        }
                    }
                    if filteredInsights != [] {
                        let appSection = INObjectSection(title: app.name, items: filteredInsights)
                        appSections.append(appSection)
                    }
                }

                let collection = INObjectCollection(sections: appSections)
                completion(collection, nil)
            }
        }
    }

    // This function returns the default card that is used when the widget is dragged on the screen
    func defaultInsight(for intent: ConfigurationIntent) -> InsightIDSelection? {
        let defaultInsight = InsightIDSelection(identifier: "00000000-0000-0000-0000-000000000000", display: "Please select an Insight")
        defaultInsight.appName = ""
        return defaultInsight
    }

    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.

        return self
    }
}
