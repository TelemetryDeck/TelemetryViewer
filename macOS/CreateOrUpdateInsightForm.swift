//
//  CreateOrUpdateInsightForm.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.09.20.
//

import SwiftUI

struct CreateOrUpdateInsightForm: View {
    // Environment
    @EnvironmentObject var api: APIRepresentative
    
    // Initialization Constants
    let app: TelemetryApp
    let editMode: Bool
    
    let insight: Insight?
    let insightGroup: InsightGroup?
    
    // Bindings
    @Binding var isPresented: Bool
    
    // State
    @State var insightCreateRequestBody: InsightDefinitionRequestBody
    
    @State private var selectedInsightGroupIndex = 0
    
    @State private var selectedDateComponentIndex = 0
    @State private var rollingWindowSize: Double = 24
    
    @State private var selectedDisplayModeIndex = 0
    private let displayModes: [InsightDisplayMode] = [.number, .lineChart, .barChart, .pieChart]
    
    init(app: TelemetryApp, editMode: Bool, requestBody: InsightDefinitionRequestBody? = nil, isPresented: Binding<Bool>, insight: Insight?, group: InsightGroup?) {
        self.app = app
        self.editMode = editMode
        self._isPresented = isPresented
        
        self.insight = insight
        self.insightGroup = group
            
        self._insightCreateRequestBody = State(initialValue: requestBody ?? InsightDefinitionRequestBody(
            order: nil,
            title: "",
            subtitle: nil,
            signalType: nil,
            uniqueUser: false,
            filters: [:],
            rollingWindowSize: -3600*24,
            breakdownKey: nil,
            displayMode: .number))
    }
    
    var body: some View {
        let saveButton = Button("Save") {
            
            if selectedDateComponentIndex == 0 {
                insightCreateRequestBody.rollingWindowSize = rollingWindowSize * -1
            } else if selectedDateComponentIndex == 1 {
                insightCreateRequestBody.rollingWindowSize = rollingWindowSize * -3600
            } else {
                insightCreateRequestBody.rollingWindowSize = rollingWindowSize * -3600*24
            }
            
            insightCreateRequestBody.displayMode = displayModes[selectedDisplayModeIndex]
            
            let group: InsightGroup = api.insightGroups[app]![selectedInsightGroupIndex]
            isPresented = false
            
            if editMode {
                insightCreateRequestBody.groupID = group.id
                api.update(insight: insight!, in: insightGroup!, in: app, with: insightCreateRequestBody)
            } else {
                api.create(insightWith: insightCreateRequestBody, in: group, for: app)
            }
            
        }
        .keyboardShortcut(.defaultAction)
        
        let cancelButton = Button("Cancel") { isPresented = false }.keyboardShortcut(.cancelAction)
        let title = (editMode ? "Edit \(insightCreateRequestBody.title)" : "New Insight")
        
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
                    TextField("Optionally, add a longer descriptive subtitle for your insight", text: $insightCreateRequestBody.subtitle.bound)
                    
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
                    TextField("What signal types are you interested in? Leave blank for any", text: $insightCreateRequestBody.signalType.bound)
                    
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
                    FilterEditView(keysAndValues: $insightCreateRequestBody.filters)
                }
                
                separator()
            }
            
            LazyVGrid(columns: columns, alignment: .trailing) {
                Text("Break down by")
                TextField("If you enter a key for the metadata payload here, you'll get a breakdown of its values.", text: $insightCreateRequestBody.breakdownKey.bound)
            }
            
            separator()
            
            LazyVGrid(columns: columns, alignment: .trailing) {
                Text("Display Mode")
                Picker(selection: $selectedDisplayModeIndex, label: Text("")) {
                    if insightCreateRequestBody.breakdownKey == nil {
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
                    TextField("Rolling Window Size", text: $rollingWindowSize.stringValue)
                    Picker(selection: $selectedDateComponentIndex, label: Text("")) {
                        Text("Seconds").tag(0)
                        Text("Hours").tag(1)
                        Text("Days").tag(2)
                    }.pickerStyle(SegmentedPickerStyle())
                }
            }
            
            separator()
            
            
            HStack {
                Spacer()
                cancelButton
                saveButton.disabled(
                    insightCreateRequestBody.title.isEmpty
                    ||
                        insightCreateRequestBody.breakdownKey == nil && ![.lineChart, .number].contains(displayModes[selectedDisplayModeIndex])
                    ||
                        insightCreateRequestBody.breakdownKey != nil && ![.barChart, .pieChart].contains(displayModes[selectedDisplayModeIndex])
                    
                    )
                
            }
            
        }
        .frame(width: 600)
        .padding()
        .onAppear() {
            // Group
            if let groupID = insightCreateRequestBody.groupID {
                selectedInsightGroupIndex = api.insightGroups[app]?.firstIndex(where: { $0.id == groupID }) ?? 0
            }
            
            // Display Mode
            switch insight?.displayMode {
            case .number:
                selectedDisplayModeIndex = 0
            case .lineChart:
                selectedDisplayModeIndex = 1
            case .barChart:
                selectedDisplayModeIndex = 2
            case .pieChart:
                selectedDisplayModeIndex = 3
            case .none:
                selectedDisplayModeIndex = 0
            }
            
            // Rolling Window
            if insightCreateRequestBody.rollingWindowSize.truncatingRemainder(dividingBy: 3600 * 24) == 0 {
                self.selectedDateComponentIndex = 2
                self.rollingWindowSize = insightCreateRequestBody.rollingWindowSize / -3600 / 24
            } else if insightCreateRequestBody.rollingWindowSize.truncatingRemainder(dividingBy: 3600) == 0 {
                selectedDateComponentIndex = 1
                self.rollingWindowSize = insightCreateRequestBody.rollingWindowSize / -3600
            } else {
                selectedDateComponentIndex = 0
                self.rollingWindowSize = insightCreateRequestBody.rollingWindowSize * -1
            }
        }
    }
    
    func separator() -> some View {
        return Rectangle()
            .frame(height: 1)
            .foregroundColor(.grayColor)
            .padding()
    }
}

//struct NewInsightForm_Previews: PreviewProvider {
//    static var platform: PreviewPlatform? = nil
//
//    static var previews: some View {
//        CreateOrUpdateInsightForm(app: MockData.app1, editMode: false, isPresented: .constant(true))
//            .environmentObject(APIRepresentative())
//            .previewLayout(.fixed(width: 600, height: 1000))
//    }
//}
