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

    var body: some View {
        ListItemView(spacing: 0) {
            let separated = title.lowercased().components(separatedBy: significantPortion)
            ForEach(separated, id: \.self) { component in
                Text(component)

                if component != separated.last {
                    Text(significantPortion).bold()
                }
            }
            Spacer()
        }
        .padding(EdgeInsets(top: 1, leading: 0, bottom: 1, trailing: 0))
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
                List {
                    ForEach(autocompletionOptions.filter { $0.lowercased().contains(text.wrappedValue.lowercased()) }, id: \.self) { option in
                        AutoCompleteListEntry(title: option, significantPortion: text.wrappedValue.lowercased())
                            .onTapGesture {
                                text.wrappedValue = option
                                isShowingAutoCompleteList = false
                                onEditingChanged?()
                            }
                    }
                }
            }
        }
    }
}

struct AutoCompletingTextField_Previews: PreviewProvider {
    static var previews: some View {
        AutoCompletingTextField(title: "Type something", text: .constant("oms"), autocompletionOptions: ["Type Something Cool", "Omsn Katapomsn", "omsn zomsn"])
    }
}
