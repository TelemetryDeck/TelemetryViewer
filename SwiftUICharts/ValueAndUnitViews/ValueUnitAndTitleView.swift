//
//  ValueView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 01.02.21.
//

import SwiftUI
import WidgetKit

public struct ValueView: View {
    public init(value: Double, shouldFormatBigNumbers: Bool) {
        self.value = value
        self.shouldFormatBigNumbers = shouldFormatBigNumbers
    }

    var value: Double
    let shouldFormatBigNumbers: Bool

    @Environment(\.widgetFamily) var family: WidgetFamily

    public var body: some View {
        SmallValueView(value: value, shouldFormatBigNumbers: shouldFormatBigNumbers)
            .if(family != .systemSmall) { $0.valueStyle() }
    }
}

struct SmallValueView: View {
    var value: Double
    let shouldFormatBigNumbers: Bool

    var body: some View {
        Text(String(value))
            .animatableNumber(value: value, shouldFormatBigNumbers: shouldFormatBigNumbers)
    }
}

public struct ValueAndUnitView: View {
    public init(value: Double, unit: String, shouldFormatBigNumbers: Bool) {
        self.value = value
        self.unit = unit
        self.shouldFormatBigNumbers = shouldFormatBigNumbers
    }

    var value: Double
    let unit: String
    let shouldFormatBigNumbers: Bool

    public var body: some View {
        HStack(spacing: 0) {
            ValueView(value: value, shouldFormatBigNumbers: shouldFormatBigNumbers)
            Text(unit).unitStyle()
        }
    }
}

public struct ValueUnitAndTitleView: View {
    @State var showFullNumber: Bool = false
    var value: Double

    let title: String
    let unit: String
    let shouldFormatBigNumbers: Bool
    let isLoading: Bool

    public init(value: Double, title: String, unit: String = "", isLoading: Bool = false, shouldFormatBigNumbers: Bool = false) {
        self.value = value
        self.title = title
        self.unit = unit
        self.isLoading = isLoading
        self.shouldFormatBigNumbers = shouldFormatBigNumbers
    }

    public var body: some View {
        VStack(alignment: .trailing) {
            ValueAndUnitView(value: value, unit: unit, shouldFormatBigNumbers: shouldFormatBigNumbers)

            Text(title)
                .foregroundColor(.gray)
                .subtitleStyle()
        }
    }
}

struct ValueView_Previews: PreviewProvider {
    static var previews: some View {
        TestValueViewContainer(value: 0)
    }
}

struct TestValueViewContainer: View {
    @State var value: Double

    var body: some View {
        VStack(spacing: 20) {
            ValueUnitAndTitleView(value: value, title: "test", unit: "s", isLoading: false, shouldFormatBigNumbers: true)
            Button("omsn") {
                value = Double.random(in: 0 ... 10_000_000)
            }
        }
    }
}
