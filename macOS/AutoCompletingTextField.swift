//
//  AutoCompletingTextField.swift
//  Telemetry Viewer (macOS)
//
//  Created by Daniel Jilg on 11.11.20.
//

import SwiftUI

struct AutoCompleteListEntry: View {
    let title: String
    let significantPortion: String

    @State private var overText = false

    var body: some View {
        ListItemView(background: overText ? Color.accentColor : Color.grayColor.opacity(0.2), spacing: 0) {
            let separated = title.lowercased().components(separatedBy: significantPortion)
            ForEach(separated, id: \.self) { component in
                Text(component)

                if component != separated.last {
                    Text(significantPortion).bold()
                }
            }
            Spacer()
        }
        .onHover { over in
            self.overText = over
        }
    }
}

struct AutoCompletingTextField: View {
    let title: String
    let text: Binding<String>
    let autocompletionOptions: [String]
    let onEditingChanged: (() -> Void)?

    @State private var isShowingAutoCompleteList: Bool = false

    init(title: String, text: Binding<String>, autocompletionOptions: [String], onEditingChanged: (() -> Void)? = nil) {
        self.title = title
        self.text = text
        self.autocompletionOptions = autocompletionOptions
        self.onEditingChanged = onEditingChanged
    }

    var body: some View {
        VStack(spacing: 0) {
            TextField(title, text: text) { editingChanged in
                if editingChanged {
                    isShowingAutoCompleteList = true
                } else {
                    isShowingAutoCompleteList = false
                    onEditingChanged?()
                }
            }

            if isShowingAutoCompleteList {
                ZStack {
                    Color.cardBackground
                    ScrollView {
                        VStack {
                            ForEach(autocompletionOptions.filter { $0.lowercased().contains(text.wrappedValue.lowercased()) }, id: \.self) { option in
                                AutoCompleteListEntry(title: option, significantPortion: text.wrappedValue.lowercased())
                                    .onTapGesture {
                                        text.wrappedValue = option
                                        isShowingAutoCompleteList = false
                                        onEditingChanged?()
                                    }
                            }
                        }
                        .padding(3)
                    }
                }
                .frame(maxHeight: 120)
                .shadow(color: Color(hue: 0, saturation: 0, brightness: 0, opacity: 0.1), radius: 5, x: 0, y: 3)
            }
        }
    }
}

struct AutoCompletingTextField_Previews: PreviewProvider {
    static var previews: some View {
        AutoCompletingTextField(title: "Type something", text: .constant("oms"), autocompletionOptions: ["Type Something Cool", "Omsn Katapomsn", "omsn zomsn"])
    }
}
