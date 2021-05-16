//
//  OptionalToggle.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 16.05.21.
//

import SwiftUI

struct OptionalToggle: View {
    let description: String
    let isOn: Binding<Bool?>
    
    var body: some View {
        if isOn.wrappedValue != nil {
            Toggle(description, isOn: isOn ?? false)
        } else {
            VStack {
            Text(description)
                HStack {
                    Button("Yes") { isOn.wrappedValue = true }
                    Button("No") { isOn.wrappedValue = false }
                }
            }
        }
    }
}

fileprivate func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}

struct OptionalToggle_Previews: PreviewProvider {
    static var previews: some View {
        OptionalToggle(description: "Receive the newsletter?", isOn: .constant(true))
        OptionalToggle(description: "Receive the newsletter?", isOn: .constant(false))
        OptionalToggle(description: "Receive the newsletter?", isOn: .constant(nil))
    }
}
