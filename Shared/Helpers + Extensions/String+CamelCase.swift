//
//  String+CamelCase.swift
//  Telemetry Viewer (iOS)
//
//  Created by Daniel Jilg on 07.12.20.
//

import Foundation

extension String {
    var camelCaseToWords: String {
        unicodeScalars.reduce("") {
            if CharacterSet.uppercaseLetters.contains($1) {
                return ($0 + " " + String($1))
            }

            return $0 + String($1)
        }
    }
}
