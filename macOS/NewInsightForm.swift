//
//  NewInsightForm.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.09.20.
//

import SwiftUI

struct NewInsightForm: View {
    // Environment
    @EnvironmentObject var api: APIRepresentative
    
    // Initialization Constants
    let app: TelemetryApp
    
    // Bindings
    @Binding var isPresented: Bool
    
    // State
    @State var insightCreateRequestBody: InsightCreateRequestBody = InsightCreateRequestBody(
        order: nil,
        title: "",
        subtitle: nil,
        signalType: nil,
        uniqueUser: false,
        filters: [:],
        rollingWindowSize: -3600*24,
        breakdownKey: nil,
        displayMode: .number)
    
    @State private var selectedInsightGroupIndex = 0
    
    @State private var breakdownKey: String = ""
    @State private var subtitle: String = ""
    @State private var signalType: String = ""
    @State private var rollingWindowSize: String = "24"
    
    @State private var selectedDisplayModeIndex = 0
    private let displayModes: [InsightDisplayMode] = [.number, .lineChart, .barChart, .pieChart]
    
    @State private var selectedDateComponentIndex = 0
        
    var body: some View {
        let saveButton = Button("Save") {
            insightCreateRequestBody.breakdownKey = breakdownKey.isEmpty ? nil : breakdownKey
            insightCreateRequestBody.subtitle = subtitle.isEmpty ? nil : subtitle
            insightCreateRequestBody.signalType = signalType.isEmpty ? nil : signalType
            
            let windowNumber: Double = NumberFormatter().number(from: rollingWindowSize)?.doubleValue ?? 0
            if selectedDateComponentIndex == 0 {
                insightCreateRequestBody.rollingWindowSize = windowNumber * -3600
            } else {
                insightCreateRequestBody.rollingWindowSize = windowNumber * -3600*24
            }
            
            insightCreateRequestBody.displayMode = displayModes[selectedDisplayModeIndex]
            
            let group: InsightGroup = api.insightGroups[app]![selectedInsightGroupIndex]
            isPresented = false
            api.create(insightWith: insightCreateRequestBody, in: group, for: app)
            
        }
        .keyboardShortcut(.defaultAction)
        
        let cancelButton = Button("Cancel") { isPresented = false }.keyboardShortcut(.cancelAction)
        let title = "New Insight"
        
        let columns = [
            GridItem(.fixed(100)),
            GridItem(.flexible()),
        ]
        
        Form {
            Group {
                Text(title)
                    .font(.title2)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                
                LazyVGrid(columns: columns, alignment: .trailing) {
                    Text("Title")
                    TextField("Give your insight a title, e.g. 'Daily Active Users'", text: $insightCreateRequestBody.title)
                    
                    Text("Subtitle")
                    TextField("Optionally, add a longer descriptive subtitle for your insight", text: $subtitle)
                    
                    Text("Group")
                    Picker(selection: $selectedInsightGroupIndex, label: Text("")) {
                        ForEach(0 ..< (api.insightGroups[app]?.count ?? 0)) {
                            Text(api.insightGroups[app]?[$0].title ?? "No Title")
                        }
                    }
                    .padding(EdgeInsets(top: 1, leading: -7, bottom: 1, trailing: 0))
                }
                
                separator()
                
                LazyVGrid(columns: columns, alignment: .trailing) {
                    Text("Signal Type")
                    TextField("What signal types are you interested in? Leave blank for any", text: $signalType)
                    
                    Text("")
                    Toggle(isOn: $insightCreateRequestBody.uniqueUser) {
                        HStack {
                            Text("Unique by User")
                            Spacer()
                        }
                    }
                }
                
                separator()
                
                LazyVGrid(columns: columns, alignment: .trailing) {
                    Text("Filters")
                    Text("Filters are coming soon")
                }
                
                separator()
            }
            
            LazyVGrid(columns: columns, alignment: .trailing) {
                Text("Break down by")
                TextField("If you enter a key for the metadata payload here, you'll get a breakdown of its values.", text: $breakdownKey)
            }
            
            separator()
            
            LazyVGrid(columns: columns, alignment: .trailing) {
                Text("Display Mode")
                Picker(selection: $selectedDisplayModeIndex, label: Text("")) {
                    if breakdownKey.isEmpty {
                        Text(InsightDisplayMode.number.rawValue.capitalized).tag(0)
                        Text(InsightDisplayMode.lineChart.rawValue.capitalized).tag(1)
                    } else {
                        Text(InsightDisplayMode.barChart.rawValue.capitalized).tag(2)
                        Text(InsightDisplayMode.pieChart.rawValue.capitalized).tag(3)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(EdgeInsets(top: 1, leading: -7, bottom: 1, trailing: 0))
                
                Text("Rolling Window")
                HStack {
                    TextField("Rolling Window Size", text: $rollingWindowSize)
                    Picker(selection: $selectedDateComponentIndex, label: Text("")) {
                        Text("Hours").tag(0)
                        Text("Days").tag(1)
                    }.pickerStyle(SegmentedPickerStyle())
                }
            }
            
            separator()
            
            
            HStack {
                Spacer()
                cancelButton
                saveButton.disabled(
                        breakdownKey.isEmpty && ![.lineChart, .number].contains(displayModes[selectedDisplayModeIndex])
                    ||
                        !breakdownKey.isEmpty && ![.barChart, .pieChart].contains(displayModes[selectedDisplayModeIndex])
                    
                    )
                
            }
            
        }
        .frame(width: 600)
        .padding()
    }
    
    func separator() -> some View {
        return Rectangle()
            .frame(height: 1)
            .foregroundColor(.grayColor)
            .padding()
    }
}

struct NewInsightForm_Previews: PreviewProvider {
    static var platform: PreviewPlatform? = nil
    
    static var previews: some View {
        NewInsightForm(app: MockData.app1, isPresented: .constant(true))
            .environmentObject(APIRepresentative())
            .previewLayout(.fixed(width: 600, height: 1000))
    }
}
