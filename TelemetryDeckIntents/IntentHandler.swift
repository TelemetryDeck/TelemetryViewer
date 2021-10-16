//
//  IntentHandler.swift
//  TelemetryDeckIntents
//
//  Created by Charlotte Böhm on 05.10.21.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}

//class IntentHandler: INExtension, SelectInsightIntentHandling {
//    func provideCharacterOptionsCollection(for intent: SelectInsightIntent, with completion: @escaping (INObjectCollection<GameCharacter>?, Error?) -> Void) {
//
//        // Iterate the available characters, creating
//        // a GameCharacter for each one.
//        let characters: [GameCharacter] = CharacterDetail.availableCharacters.map { character in
//            let gameCharacter = GameCharacter(
//                identifier: character.name,
//                display: character.name
//            )
//            gameCharacter.name = character.name
//            return gameCharacter
//        }
//
//        // Create a collection with the array of characters.
//        let collection = INObjectCollection(items: characters)
//
//        // Call the completion handler, passing the collection.
//        completion(collection, nil)
//    }
//}
