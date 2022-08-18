//
//  CustomPickers.swift
//  Telemetry Viewer (iOS)
//
//  Created by Martin Václavík on 29.12.2021.
//

import SwiftUI
import DataTransferObjects

protocol PickerItem: Identifiable, Equatable {
    var name: String { get }
    var explanation: String { get }
}

struct DetailedPicker<Item: PickerItem, Summary: View>: View {
    let title: LocalizedStringKey?
    let summary: Summary

    @Binding var selectedItem: Item
    let options: [Item]

    var body: some View {
        NavigationLink {
            List {
                Section {
                    ForEach(options) { item in
                        Button {
                            selectedItem = item
                        } label: {
                            HStack {
                                Text(item.name)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedItem == item {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                } footer: {
                    Text(selectedItem.explanation)
                }
            }.listStyle(.grouped)
        } label: {
            HStack {
                if let title = title {
                    Text(title)
                }
                Spacer()
                summary
            }
        }
    }
}

struct GroupByPicker: View {
    let title: LocalizedStringKey?

    @Binding var selection: InsightGroupByInterval
    let options: [InsightGroupByInterval]
    let description: String

    var body: some View {
        NavigationLink {
            List {
                Section {
                    ForEach(options, id: \.self) { item in
                        Button {
                            selection = item
                        } label: {
                            HStack {
                                Text(item.rawValue.capitalized)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selection == item {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                } footer: {
                    Text(description)
                }
            }.listStyle(.grouped)
        } label: {
            HStack {
                if let title = title {
                    Text(title)
                }
                Spacer()
                Text(selection.rawValue.capitalized)
            }
        }
    }
}

struct PreviewPickerItem: PickerItem {
    var summary: String?
    let id = UUID()
    var explanation: String
    var name: String
}

struct DetailedPicker_Previews: PreviewProvider {
    @State static var asd = PreviewPickerItem(explanation: "Picker", name: "Test")
    static var previews: some View {
        NavigationView {
            List {
                DetailedPicker(title: "DetailedPicker", summary: Text(asd.name), selectedItem: $asd, options: [PreviewPickerItem(explanation: "Item 1", name: "First"), PreviewPickerItem(explanation: "Item 2", name: "Second")])
            }
        }
    }
}
