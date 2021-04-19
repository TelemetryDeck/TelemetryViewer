//
//  ValueNumberText.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 19.04.21.
//

import SwiftUI

struct ValueStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.system(size: 28, weight: .light, design: .rounded))
    }
}

struct SmallValueStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.system(size: 12, weight: .light, design: .rounded))
    }
}

struct UnitStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.system(size: 28, weight: .thin, design: .rounded))
    }
}

struct SubtitleStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.system(size: 12, weight: .light, design: .default))
    }
}

struct SelectedForegroundColorModiffier: ViewModifier {
    let isSelected: Bool
    
    func body(content: Content) -> some View {
        if isSelected {
            content
        } else {
            content.foregroundColor(.cardBackground)
        }
    }
}

struct AnimatableNumberModifier: AnimatableModifier {
    var value: Double
    let shouldFormatBigNumbers: Bool
    let showFullNumber: Bool = false

    var animatableData: CGFloat {
        get { CGFloat(value) }
        set { value = Double(newValue) }
    }
    
    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    var formattedNumberString: String {
        if shouldFormatBigNumbers && !showFullNumber {
            return BigNumberFormatter.shortDisplay(for: value)
        } else {
            return formatter.string(from: NSNumber(value: value)) ?? "–"
        }
    }

    func body(content: Content) -> some View {
        Text(formattedNumberString)
            
    }
}


extension View {
    func valueStyle() -> some View {
        modifier(ValueStyleModifier())
    }
    
    func smallValueStyle() -> some View {
        modifier(SmallValueStyleModifier())
    }
    
    func unitStyle() -> some View {
        modifier(UnitStyleModifier())
    }
    
    func subtitleStyle() -> some View {
        modifier(SubtitleStyleModifier())
    }
    
    func togglesForeground(isSelected: Bool) -> some View {
        modifier(SelectedForegroundColorModiffier(isSelected: isSelected))
    }
}

extension Text {
    func animatableNumber(value: Double, shouldFormatBigNumbers: Bool = false) -> some View {
        modifier(AnimatableNumberModifier(value: value, shouldFormatBigNumbers: shouldFormatBigNumbers))
    }
}
