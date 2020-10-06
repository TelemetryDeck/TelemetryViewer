//
//  Publisher+Validation.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.10.20.
//

import Foundation
import Combine

typealias DataTaskResult = (data: Data, response: URLResponse)

enum ValidationError: Error {
    case error(Error)
    case jsonError(Data)
}

extension Publisher where Output == DataTaskResult {
    func validateStatusCode(_ isValid: @escaping (Int) -> Bool) -> AnyPublisher<Output, ValidationError> {
        return validateResponse { (data, response) in
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            return isValid(statusCode)
        }
    }
    
    func validateResponse(_ isValid: @escaping (DataTaskResult) -> Bool) -> AnyPublisher<Output, ValidationError> {
        return self
            .mapError { .error($0) }
            .flatMap { (result) -> AnyPublisher<DataTaskResult, ValidationError> in
                let (data, _) = result
                if isValid(result) {
                    return Just(result)
                        .setFailureType(to: ValidationError.self)
                        .eraseToAnyPublisher()
                } else {
                    return Fail(outputType: Output.self, failure: .jsonError(data))
                        .eraseToAnyPublisher()
                }}
            .eraseToAnyPublisher()
    }
}


