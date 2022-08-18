//
//  SwiftUIView.swift
//  SwiftUIView
//
//  Created by Daniel Jilg on 18.08.21.
//

#if canImport(Shimmer)
import Shimmer
#else
public extension View {
    @ViewBuilder func shimmering(
        active: Bool = true, duration: Double = 1.5, bounce: Bool = false
    ) -> some View {
        if active {
            opacity(0.5)
        } else {
            self
        }
    }
}
#endif

import DataTransferObjects
import SwiftUI

struct LabelLoadingStateIndicator: View {
    let systemImage: String
    let title: String?
    let loadingState: LoadingState
    
    init(loadingState: LoadingState, title: String? = nil, systemImage: String) {
        self.title = title
        self.loadingState = loadingState
        self.systemImage = systemImage
    }
    
    private var resolvedText: String {
        guard let title = title else {
            switch loadingState {
            case .idle:
                return "Waiting"
            case .loading:
                return "Loading"
            case .finished:
                return "Finished"
            case .error:
                return "Error"
            }
        }

        return title
    }
    
    private var resolvedSystemImage: String {
        switch loadingState {
        case .idle:
            return systemImage
        case .loading:
            return "clock.arrow.2.circlepath"
        case .finished:
            return systemImage
        case .error:
            return "exclamationmark.triangle"
        }
    }
    
    var body: some View {
        Group {
            if title == nil {
                Label(resolvedText, systemImage: resolvedSystemImage)
                    .redacted(reason: .placeholder)
            } else {
                Label(resolvedText, systemImage: resolvedSystemImage)
            }
        }
        .shimmering(active: loadingState == .loading)
    }
}

struct TinyLoadingStateIndicator: View {
    let title: String?
    let loadingState: LoadingState
    
    init(loadingState: LoadingState, title: String? = nil) {
        self.title = title
        self.loadingState = loadingState
    }
    
    private var resolvedText: String {
        guard let title = title else {
            switch loadingState {
            case .idle:
                return "Waiting"
            case .loading:
                return "Loading"
            case .finished:
                return "Finished"
            case .error:
                return "Error"
            }
        }

        return title
    }
    
    var body: some View {
        Group {
            if title == nil {
                Text(resolvedText)
                    .redacted(reason: .placeholder)
            } else {
                Text(resolvedText)
            }
        }
        .shimmering(active: loadingState == .loading)
    }
}

struct LoadingStateIndicator: View {
    let title: String?
    let loadingState: LoadingState
    
    init(loadingState: LoadingState, title: String? = nil) {
        self.title = title
        self.loadingState = loadingState
    }
    
    var body: some View {
        Label {
            VStack(alignment: .leading) {
                if let title = title {
                    Text(title)
                        .bold()
                } else {
                    Text("Meaningless whisper")
                        .bold()
                        .redacted(reason: .placeholder)
                }
                
                Group {
                    switch loadingState {
                    case .idle:
                        Text("Waiting to load")
                    case .loading:
                        Text("Loading")
                    case .finished(let date):
                        Text("Loaded ") + Text(date, style: .relative) + Text(" ago")
                    case .error(let string, let date):
                        Text(date, style: .relative) + Text(" ago: ") + Text(string)
                    }
                }
                .foregroundColor(.secondary)
                .font(.caption)
            }
        } icon: {
            switch loadingState {
            case .idle:
                Image(systemName: "circle.dashed")
            case .loading:
                ProgressView()
                    .scaleEffect(progressViewScale, anchor: .center)
            case .finished:
                Image(systemName: "checkmark.circle")
            case .error:
                Image(systemName: "exclamationmark.arrow.circlepath")
            }
        }
    }
}

struct SondrineLoadingStateIndicator: View {
    let title: String?
    let loadingState: LoadingState
    
    init(loadingState: LoadingState, title: String? = nil) {
        self.title = title
        self.loadingState = loadingState
    }
    
    var body: some View {
        Group {
            switch loadingState {
            case .idle:
                SondrineAnimation()
            case .loading:
                SondrineAnimation()
            case .finished:
                SondrineAnimation()
            case .error(let string, let date):
                GeometryReader { geometry in
                    HStack {
                        Image("SondrineError")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 1/4, height: geometry.size.height, alignment: .center)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(date, style: .relative).fontWeight(.bold) + Text(" ago: ").fontWeight(.bold) + Text(string)
                            Text("Tap here to try again.").fontWeight(.bold)
                        }
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .frame(width: geometry.size.width * 3/4, height: geometry.size.height, alignment: .leading)
                    }
                    .padding(.trailing)
                }
            }
        }
        .frame(maxHeight: 100)
    }
}

struct IconOnlyLoadingStateIndicator: View {
    let loadingState: LoadingState
    
    init(loadingState: LoadingState) {
        self.loadingState = loadingState
    }
    
    var body: some View {
        switch loadingState {
        case .idle:
            Image(systemName: "circle.dashed").opacity(0.5)
        case .loading:
            ProgressView()
                .scaleEffect(progressViewScale, anchor: .center)
        case .finished:
            Image(systemName: "checkmark.circle").opacity(0.5)
        case .error:
            Image(systemName: "exclamationmark.arrow.circlepath").opacity(0.5)
        }
    }
}

struct UnobtrusiveIconOnlyLoadingStateIndicator: View {
    let loadingState: LoadingState
    
    init(loadingState: LoadingState) {
        self.loadingState = loadingState
    }
    
    var body: some View {
        switch loadingState {
        case .idle:
            Image(systemName: "circle.dashed").opacity(0.5)
        case .loading:
            ProgressView()
                .scaleEffect(progressViewScale, anchor: .center)
                .frame(width: 10, height: 10, alignment: .center)
        case .finished:
            EmptyView()
        case .error:
            Image(systemName: "exclamationmark.arrow.circlepath").opacity(0.5)
        }
    }
}

struct SondrineLoadingStateIndicator_Previews: PreviewProvider {
    static var previews: some View {
        SondrineLoadingStateIndicator(loadingState: .loading)
            .preferredColorScheme(.dark)
        SondrineLoadingStateIndicator(loadingState: .error(TransferError.transferFailed.localizedDescription, Date()))
    }
}
