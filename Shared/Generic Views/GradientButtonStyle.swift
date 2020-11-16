//
//  GradientButtonStyle.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 16.11.20.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(configuration.isPressed ? Color.white.opacity(0.5) : .white)
            .background(LinearGradient(gradient: Gradient(colors: [Color("Torange"), Color("Torange").opacity(0.7)]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(15)
            .shadow(color: Color(hue: 0, saturation: 0, brightness: 0, opacity: 0.1), radius: configuration.isPressed ? 4 : 5, x: 0, y: configuration.isPressed ? 1 : 3)
            .padding(.horizontal, 20)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(configuration.isPressed ? Color("Torange").opacity(0.5) : Color("Torange"))
            .background(Color("CardBackgroundColor"))
            .cornerRadius(15)
            .shadow(color: Color(hue: 0, saturation: 0, brightness: 0, opacity: 0.1), radius: configuration.isPressed ? 4 : 5, x: 0, y: configuration.isPressed ? 1 : 3)
            .padding(.horizontal, 20)
    }
}

struct TertiaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .foregroundColor(configuration.isPressed ? Color("Torange").opacity(0.5) : Color("Torange"))
            .font(Font.system(size: 10, weight: .semibold, design: .default))
    }
}

