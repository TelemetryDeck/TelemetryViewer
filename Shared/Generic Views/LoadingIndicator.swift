//
//  LoadingIndicator.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.02.21.
//

import SwiftUI

struct LoadingIndicator: View {
    enum LoadingState {
        case notLoading
        case loadingIndefinitely
        case loadingTime(time: TimeInterval)
    }

    @State var loadingState: LoadingState = .notLoading

    private var isLoading: Bool {
        switch loadingState {
        case .notLoading:
            return false
        default:
            return true
        }
    }

    private var barOffset: CGFloat {
        switch loadingState {
        case .notLoading:
            return -(backgroundBarWidhth - barWidth) / 2
        case .loadingIndefinitely:
            return (backgroundBarWidhth - barWidth) / 2
        case .loadingTime(time: _):
            return 0
        }
    }

    private var barWidth: CGFloat {
        switch loadingState {
        case .notLoading:
            return 30
        case .loadingIndefinitely:
            return 30
        case .loadingTime(time: _):
            return backgroundBarWidhth
        }
    }

    private var shouldAutoreverse: Bool {
        switch loadingState {
        case .notLoading:
            return true
        case .loadingIndefinitely:
            return true
        case .loadingTime(time: _):
            return false
        }
    }

    private var animationDuration: Double {
        switch loadingState {
        case .notLoading:
            return 1
        case .loadingIndefinitely:
            return 1
        case let .loadingTime(time: time):
            return time + 1
        }
    }

    private let backgroundBarWidhth: CGFloat = 250

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color.grayColor.opacity(0.3), lineWidth: 3)
                .frame(width: backgroundBarWidhth, height: 3)

            RoundedRectangle(cornerRadius: 3)
                .stroke(Color.accentColor, lineWidth: 3)
                .frame(width: barWidth, height: 3)
                .offset(x: barOffset, y: 0)
                .animation(Animation.linear(duration: animationDuration).repeatForever(autoreverses: shouldAutoreverse))
        }
        .padding()
        .onAppear {
            self.loadingState = .loadingIndefinitely
        }
    }
}

struct LoadingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        LoadingIndicator()
    }
}
