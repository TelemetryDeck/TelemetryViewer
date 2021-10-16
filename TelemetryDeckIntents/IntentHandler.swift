//
//  IntentHandler.swift
//  TelemetryDeckIntents
//
//  Created by Charlotte Böhm on 05.10.21.
//

import Intents

class IntentHandler: INExtension, ConfigurationIntentHandling {
    
    let api: APIClient
    let cacheLayer: CacheLayer
    let errors: ErrorService
    let insightService: InsightService

    override init() {

        self.api = APIClient()
        self.cacheLayer = CacheLayer()
        self.errors = ErrorService()

        self.insightService = InsightService(api: api, cache: cacheLayer, errors: errors)
        
        super.init()
    }
    
    func provideInsightOptionsCollection(for intent: ConfigurationIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<InsightIDSelection>?, Error?) -> Void) {
        insightService.widgetableInsights { insights in
            print(insights)
            let selectableInsights: [InsightIDSelection] = insights.map {
                let selectableInsight = InsightIDSelection(identifier: $0.id.uuidString, display: $0.title)
                return selectableInsight
            }
            let collection = INObjectCollection(items: selectableInsights)
            completion(collection, nil)
        }
    }
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}
