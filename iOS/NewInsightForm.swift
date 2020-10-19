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
        
        NavigationView {
            Form {
                Section(header: Text("Title, Subtitle and Group"), footer: Text("Give your insight a title, and optionally, add a longer descriptive subtitle for your insight. All insights belong to an insight group.")) {
                    TextField("Title e.g. 'Daily Active Users'", text: $insightCreateRequestBody.title)
                    TextField("Optional Subtitle", text: $subtitle)
                    
                    Picker(selection: $selectedInsightGroupIndex, label: Text("Insight Group")) {
                        ForEach(0 ..< (api.insightGroups[app]?.count ?? 0)) {
                            Text(api.insightGroups[app]?[$0].title ?? "No Title")
                        }
                    }
                }
                
                Section(header: Text("Signal Type"), footer: Text(("What signal type are you interested in (e.g. appLaunchedRegularly)? Leave blank for any"))) {
                    TextField("All Signals", text: $signalType)
                    Toggle(isOn: $insightCreateRequestBody.uniqueUser) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Unique by User")
                                Text("Check to count each user only once")
                                    .font(.footnote)
                                    .foregroundColor(.grayColor)
                            }
                            Spacer()
                        }
                    }
                }
                
                Section(header: Text("Filters")) {
                    Text("Filters are coming soon")
                }
                
                Section(header: Text("Breakdown"), footer: Text("If you enter a key for the metadata payload here (e.g. systemVersion), you'll get a breakdown of its values.")) {
                    TextField("No breakdown", text: $breakdownKey)
                }
                
                Section(header: Text("Display")) {
                    
                    Picker(selection: $selectedDisplayModeIndex, label: Text("Display As")) {
                        if breakdownKey.isEmpty {
                            Text(InsightDisplayMode.number.rawValue.capitalized).tag(0)
                            Text(InsightDisplayMode.lineChart.rawValue.capitalized).tag(1)
                        } else {
                            Text(InsightDisplayMode.barChart.rawValue.capitalized).tag(2)
                            Text(InsightDisplayMode.pieChart.rawValue.capitalized).tag(3)
                        }
                    }
                    .padding(EdgeInsets(top: 1, leading: -7, bottom: 1, trailing: 0))
                    
                    HStack {
                        Text("Rolling Window")
                        TextField("Rolling Window Size", text: $rollingWindowSize).multilineTextAlignment(.trailing)
                        Picker(selection: $selectedDateComponentIndex, label: Text("")) {
                            Text("Hours").tag(0)
                            Text("Days").tag(1)
                        }.pickerStyle(SegmentedPickerStyle())
                    }
                    
                }
            }
            .navigationTitle("New Insight")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    cancelButton
                }
                ToolbarItem(placement: .confirmationAction) {
                    saveButton.disabled(
                        insightCreateRequestBody.title.isEmpty
                            ||
                        breakdownKey.isEmpty && ![.lineChart, .number].contains(displayModes[selectedDisplayModeIndex])
                            ||
                            !breakdownKey.isEmpty && ![.barChart, .pieChart].contains(displayModes[selectedDisplayModeIndex])
                        
                    )
                }
            }
        }
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
