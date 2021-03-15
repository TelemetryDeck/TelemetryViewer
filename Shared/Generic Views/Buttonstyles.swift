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
            .background(LinearGradient(gradient: Gradient(colors: [Color.telemetryOrange, Color.telemetryOrange.opacity(0.7)]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(15)
            .shadow(color: Color(hue: 0, saturation: 0, brightness: 0, opacity: 0.1), radius: configuration.isPressed ? 4 : 5, x: 0, y: configuration.isPressed ? 1 : 3)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(configuration.isPressed ?Color.telemetryOrange.opacity(0.5) : Color.telemetryOrange)
            .background(Color.cardBackground)
            .cornerRadius(15)
            .shadow(color: Color(hue: 0, saturation: 0, brightness: 0, opacity: 0.1), radius: configuration.isPressed ? 4 : 5, x: 0, y: configuration.isPressed ? 1 : 3)
    }
}

struct SmallPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .foregroundColor(configuration.isPressed ?Color.telemetryOrange.opacity(0.5) : Color.telemetryOrange)
            .font(Font.system(size: 12, weight: .semibold, design: .default))
            .padding(4)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        configuration.isPressed ?Color.telemetryOrange.opacity(0.5) : Color.telemetryOrange,
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

struct CardButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Self.Configuration) -> some View {
        VStack(spacing: 0) {
            configuration.label
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(configuration.isPressed ? Color.telemetryOrange.opacity(0.2) : (isSelected ? Color.telemetryOrange.opacity(0.8) : Color.cardBackground))
                .accentColor(isSelected ? Color.cardBackground : Color.telemetryOrange)
        }
    }
}
