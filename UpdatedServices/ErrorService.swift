//
//  ErrorService.swift
//  ErrorService
//
//  Created by Daniel Jilg on 17.08.21.
//

import Foundation

class ErrorService: ObservableObject {
    struct DisplayableError {
        let occurredAt: Date
        let title: String
        let description: String
    }
    
    @Published var errors: [DisplayableError] = []
    
    func handle(transferError: TransferError) {
        errors.append(DisplayableError(occurredAt: Date(), title: "Transfer Error", description: transferError.localizedDescription))
        
        #if DEBUG
        print(transferError)
        #endif
    }
    
    func handle(error: Error) {
        errors.append(DisplayableError(occurredAt: Date(), title: "General Error", description: error.localizedDescription))
        
        #if DEBUG
        print(error)
        #endif
    }
}
