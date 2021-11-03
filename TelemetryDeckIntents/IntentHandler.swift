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
            let appSections: [INObjectSection<InsightIDSelection>] = apps.map {
                let appSection = INObjectSection(title: $0.name, items: $0.insights.map { insight in
                    InsightIDSelection(identifier: insight.id.uuidString, display: insight.title)
                })
                return appSection
            }

            let collection = INObjectCollection(sections: appSections)
            completion(collection, nil)
        }
    }

    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.

        return self
    }
}
