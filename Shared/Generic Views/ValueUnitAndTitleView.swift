//
//  ValueView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 01.02.21.
//

import SwiftUI

struct ValueView: View {
    var value: Double
    let shouldFormatBigNumbers: Bool
    
    var body: some View {
        SmallValueView(value: value, shouldFormatBigNumbers: shouldFormatBigNumbers)
            .valueStyle()
    }
}

struct SmallValueView: View {
    var value: Double
    let shouldFormatBigNumbers: Bool
    
    var body: some View {
        Text(String(value))
            .animatableNumber(value: value,  shouldFormatBigNumbers: shouldFormatBigNumbers)
            .animation(.easeOut)
    }
}

struct ValueAndUnitView: View {
    var value: Double
    let unit: String
    let shouldFormatBigNumbers: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            ValueView(value: value, shouldFormatBigNumbers: shouldFormatBigNumbers)
            Text(unit).unitStyle()
        }
    }
}


struct ValueUnitAndTitleView: View {
    @State var showFullNumber: Bool = false
    var value: Double
    
    let title: String
    let unit: String
    let shouldFormatBigNumbers: Bool
    let isLoading: Bool
    
    init(value: Double, title: String, unit: String = "", isLoading: Bool = false, shouldFormatBigNumbers: Bool = false) {
        self.value = value
        self.title = title
        self.unit = unit
        self.isLoading = isLoading
        self.shouldFormatBigNumbers = shouldFormatBigNumbers
    }
    
    var body: some View {
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
            Button ("omsn") {
                value = Double.random(in: 0...10000000)
            }
        }
    }
}

