//
//  AutoCompletingTextField.swift
//  Telemetry Viewer (macOS)
//
//  Created by Daniel Jilg on 11.11.20.
//

import SwiftUI

struct AutoCompleteListEntry: View {
    let title: String
    
    @State private var overText = false
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(overText ? Color.accentColor : Color.clear)
        .onHover { over in
            self.overText = over
        }
    }
}

struct AutoCompletingTextField: View {
    let title: String
    let text: Binding<String>
    let autocompletionOptions: [String]
    
    @State private var isShowingAutoCompleteList: Bool = false
    
    var body: some View {
        VStack (spacing: 0){
            TextField(title, text: text) { editingChanged in
                if editingChanged {
                    isShowingAutoCompleteList = true
                } else {
                    isShowingAutoCompleteList = false
                }
            }
            
            if isShowingAutoCompleteList {
                ZStack {
                    Color("CardBackgroundColor")
                    ScrollView {
                        VStack {
                            ForEach(autocompletionOptions.filter( { $0.lowercased().contains(text.wrappedValue.lowercased()) }), id: \.self) { option in
                                AutoCompleteListEntry(title: option)
                                    .onTapGesture {
                                        text.wrappedValue = option
                                        isShowingAutoCompleteList = false
                                    }
                            }
                        }
                        .padding(3)
                    }
                }
                .frame(maxHeight: 150)
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
