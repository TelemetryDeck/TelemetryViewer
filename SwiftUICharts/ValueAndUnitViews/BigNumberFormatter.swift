//
//  BigNumberFormatter.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 29.01.21.
//

import Foundation

class BigNumberFormatter {
    static func roundedNeighbor(for numberString: String) -> Int? {
        guard let number = Double(numberString) else { return nil }

        let length = numberString.count
        let divisor = (pow(10, length - 1) as NSDecimalNumber).doubleValue

        let result = number / divisor
        return Int(result.rounded() * divisor)
    }

    static func shortDisplay(for number: Double) -> String {
        guard number >= 1000 else { return NumberFormatter().string(from: NSNumber(value: number)) ?? "—" }

        // Available Units
        let units: [Double] = [
            1000,
            1_000_000,
            1_000_000_000,
            1_000_000_000_000
        ]
        let unitPrefixes: [Double: String] = [
            1000: "K",
            1_000_000: "M",
            1_000_000_000: "B",
            1_000_000_000_000: "T"
        ]

        // Find out the unit for the specified number
        var unit: Double = 1
        for currentUnit in units where number / currentUnit > 1 {
            unit = currentUnit
        }

        // round to the nearest unit and add its prefix
        let unitPrefix = unitPrefixes[unit] ?? ""
        return "\((number * 10 / unit).rounded() / 10)\(unitPrefix)"
    }

    static func shortDisplay(for numberString: String) -> String {
        guard let number = Double(numberString) else { return numberString }
        return shortDisplay(for: number)
    }
}
