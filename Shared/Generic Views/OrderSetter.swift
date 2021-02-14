//
//  OrderSetter.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 14.01.21.
//

import SwiftUI

struct OrderSetter: View {
    @Binding var order: Double

    #if os(macOS)
        var body: some View {
            HStack {
                Button(action: {
                    order -= 1
                }, label: {
                    Image(systemName: "arrow.left")
                })

                Spacer()

                Text(String(format: "%.0f", order))

                Spacer()

                Button(action: {
                    order += 1
                }, label: {
                    Image(systemName: "arrow.right")
                })
            }
        }
    #else
        var body: some View {
            Button(action: {
                order += 1
            }, label: {
                Image(systemName: "arrow.up")
            })

            Text(String(format: "%.0f", order))

            Button(action: {
                order -= 1
            }, label: {
                Image(systemName: "arrow.down")
            })
        }
    #endif
}

struct OrderSetter_Previews: PreviewProvider {
    @State static var order: Double = -1

    static var previews: some View {
        OrderSetter(order: $order)
    }
}
