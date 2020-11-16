//
//  CardView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 02.09.20.
//

import SwiftUI

struct SingleKeyValueView: View {
    private let key: Text
    private let value: Text

    public init(key: Text, value: Text) {
        self.key = key
        self.value = value
    }

    var body : some View {
        HStack {
            key.foregroundColor(.grayColor)
            value
        }
    }
}
