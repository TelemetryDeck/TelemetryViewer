//
//  IntentHandler.swift
//  TelemetryDeckIntents
//
//  Created by Charlotte Böhm on 05.10.21.
//

import Intents
import TelemetryClient
import TelemetryDeckClient

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

        self.insightService = InsightService(api: api, cache: cacheLayer, errors: errors)

        super.init()
    }

    func provideInsightOptionsCollection(for intent: ConfigurationIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<InsightIDSelection>?, Error?) -> Void) {
        insightService.widgetableInsights { apps in
            let appSections: [INObjectSection<InsightIDSelection>] = apps.map { app in
                let appSection = INObjectSection(title: app.name, items: app.insights.map { insight -> InsightIDSelection in
                    let selectedInsight = InsightIDSelection(identifier: insight.id.uuidString, display: insight.title)
                    selectedInsight.appName = app.name
                    return selectedInsight
                })
                return appSection
            }

            let collection = INObjectCollection(sections: appSections)
            completion(collection, nil)
        }
    }
    
// This function returns the default card that is used when the widget is dragged on the screen
    func defaultInsight(for intent: ConfigurationIntent) -> InsightIDSelection? {
        let defaultInsight = InsightIDSelection(identifier: "00000000-0000-0000-0000-000000000000", display: "Please select an Insight")
        defaultInsight.appName = "Default App Name"
        return defaultInsight
    }

    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.

        return self
    }
}
