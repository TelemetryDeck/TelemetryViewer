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
    }
}

struct SmallPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .foregroundColor(configuration.isPressed ? Color("Torange").opacity(0.5) : Color("Torange"))
            .font(Font.system(size: 12, weight: .semibold, design: .default))
            .padding(4)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        configuration.isPressed ? Color("Torange").opacity(0.5) : Color("Torange"),
                        lineWidth: 1
                    )
            )
    }
}

struct SmallSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .foregroundColor(configuration.isPressed ? Color.grayColor.opacity(0.5) : Color.grayColor)
            .font(Font.system(size: 12, weight: .semibold, design: .default))
            .padding(4)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        configuration.isPressed ? Color.grayColor.opacity(0.5) : Color.grayColor,
                        lineWidth: 1
                    )
            )
    }
}

struct BackButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? Color.grayColor.opacity(0.5) : Color.grayColor)
            .font(Font.system(size: 12, weight: .semibold, design: .default))
            .padding(4)
    }
}

struct IconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? Color.accentColor.opacity(0.5) : Color.accentColor)
            .padding(2)
    }
}
