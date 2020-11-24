//
//  NewInsightForm.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.09.20.
//

import SwiftUI

struct CreateOrUpdateInsightForm: View {
    // Environment
    @EnvironmentObject var api: APIRepresentative
    @Environment(\.presentationMode) var presentationMode
    
    // Initialization Constants
    let app: TelemetryApp
    let editMode: Bool
    
    let insight: Insight?
    let insightGroup: InsightGroup?
    
    // State
    @State var insightDefinitionRequestBody: InsightDefinitionRequestBody
    
    @State private var selectedInsightGroupIndex = 0
    
    @State private var selectedDateComponentIndex = 0
    @State private var rollingWindowSize: Double = 24
    
    @State private var selectedDisplayModeIndex = 0
    private let displayModes: [InsightDisplayMode] = [.raw, .lineChart, .barChart, .pieChart]
    
    init(app: TelemetryApp, editMode: Bool, requestBody: InsightDefinitionRequestBody? = nil, insight: Insight?, group: InsightGroup?) {
        self.app = app
        self.editMode = editMode
        
        self.insight = insight
        self.insightGroup = group
            
        self._insightDefinitionRequestBody = State(initialValue: requestBody ?? InsightDefinitionRequestBody(
            order: nil,
            title: "",
            subtitle: nil,
            signalType: nil,
            uniqueUser: false,
            filters: [:],
            rollingWindowSize: -3600*24,
            breakdownKey: nil,
            displayMode: .raw,
            isExpanded: false))
    }
    
    var body: some View {
        let saveButton = Button("Save") {
            
            if selectedDateComponentIndex == 0 {
                insightDefinitionRequestBody.rollingWindowSize = rollingWindowSize * -1
            } else if selectedDateComponentIndex == 1 {
                insightDefinitionRequestBody.rollingWindowSize = rollingWindowSize * -3600
            } else {
                insightDefinitionRequestBody.rollingWindowSize = rollingWindowSize * -3600*24
            }
            
            insightDefinitionRequestBody.displayMode = displayModes[selectedDisplayModeIndex]
            
            let group: InsightGroup = api.insightGroups[app]![selectedInsightGroupIndex]
            self.presentationMode.wrappedValue.dismiss()
            
            if editMode {
                insightDefinitionRequestBody.groupID = group.id
                api.update(insight: insight!, in: insightGroup!, in: app, with: insightDefinitionRequestBody)
            } else {
                api.create(insightWith: insightDefinitionRequestBody, in: group, for: app)
            }
            
        }
        .keyboardShortcut(.defaultAction)
        
        let deleteButton = Button("Delete \(insightDefinitionRequestBody.title)") {
            if let insight = insight, let insightGroup = insightGroup {
                self.presentationMode.wrappedValue.dismiss()
                api.delete(insight: insight, in: insightGroup, in: app)
            }
        }

            Form {
                Section(header: Text("Title, Subtitle and Group"), footer: Text("Give your insight a title, and optionally, add a longer descriptive subtitle for your insight. All insights belong to an insight group.")) {
                    TextField("Title e.g. 'Daily Active Users'", text: $insightDefinitionRequestBody.title)
                    TextField("Optional Subtitle", text: $insightDefinitionRequestBody.subtitle.bound)
                    
                    Toggle(isOn: $insightDefinitionRequestBody.isExpanded, label: {
                        Text("Show Expanded")
                    })
                    
                    Picker(selection: $selectedInsightGroupIndex, label: Text("Insight Group")) {
                        ForEach(0 ..< (api.insightGroups[app]?.count ?? 0)) {
                            Text(api.insightGroups[app]?[$0].title ?? "No Title")
                        }
                    }.pickerStyle(WheelPickerStyle())
                }
                
                Section(header: Text("Signal Type"), footer: Text(("What signal type are you interested in (e.g. appLaunchedRegularly)? Leave blank for any"))) {
                    AutoCompletingTextField(
                        title: "All Signals",
                        text: $insightDefinitionRequestBody.signalType.bound,
                        autocompletionOptions: api.lexiconSignalTypes[app, default: []].map { $0.type })
                    
                    Toggle(isOn: $insightDefinitionRequestBody.uniqueUser) {
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
                
                Section(header: Text("Filters"), footer: Text("To add a filter, type a key into the text field and tap 'Add'")) {
                    FilterEditView(keysAndValues: $insightDefinitionRequestBody.filters)
                }
                
                Section(header: Text("Breakdown"), footer: Text("If you enter a key for the metadata payload here (e.g. systemVersion), you'll get a breakdown of its values.")) {
                    TextField("No breakdown", text: $insightDefinitionRequestBody.breakdownKey.bound)
                }
                
                Section(header: Text("Display")) {
                    
                    Picker(selection: $selectedDisplayModeIndex, label: Text("Display As")) {
                        Text(InsightDisplayMode.raw.rawValue.capitalized).tag(0)
                        Text(InsightDisplayMode.lineChart.rawValue.capitalized).tag(1)
                        Text(InsightDisplayMode.barChart.rawValue.capitalized).tag(2)
                        Text(InsightDisplayMode.pieChart.rawValue.capitalized).tag(3)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(EdgeInsets(top: 1, leading: -7, bottom: 1, trailing: 0))
                    
                    HStack {
                        Text("Rolling Window")
                        TextField("Rolling Window Size", text: $rollingWindowSize.stringValue).multilineTextAlignment(.trailing)
                        Picker(selection: $selectedDateComponentIndex, label: Text("")) {
                            Text("Seconds").tag(0)
                            Text("Hours").tag(1)
                            Text("Days").tag(2)
                        }.pickerStyle(SegmentedPickerStyle())
                    }
                    
                }
                
                if editMode {
                    deleteButton.foregroundColor(.red)
                }
            }
//                .navigationTitle(editMode ? "Edit \(insightDefinitionRequestBody.title)" : "New Insight")
//                .toolbar {
//                    ToolbarItem(placement: .confirmationAction) {
//                        saveButton.disabled(insightDefinitionRequestBody.title.isEmpty)
//                    }
//                    
//                    ToolbarItem(placement: .cancellationAction) {
//                        Button("Close") {
//                            self.presentationMode.wrappedValue.dismiss()
//                        }
//                    }
//                }
                .onAppear() {
                    // Fetch Signal and Payload Lexicon
                    api.getSignalTypes(for: app)
                    api.getPayloadKeys(for: app)
                    
                    // Group
                    if let groupID = insightDefinitionRequestBody.groupID {
                        selectedInsightGroupIndex = api.insightGroups[app]?.firstIndex(where: { $0.id == groupID }) ?? 0
                    }
                    
                    // Display Mode
                    switch insight?.displayMode {
                    case .raw, .number:
                        selectedDisplayModeIndex = 0
                    case .lineChart:
                        selectedDisplayModeIndex = 1
                    case .barChart:
                        selectedDisplayModeIndex = 2
                    case .pieChart:
                        selectedDisplayModeIndex = 3
                    case .none:
                        selectedDisplayModeIndex = -1
                    }
                    
                    // Rolling Window
                    if insightDefinitionRequestBody.rollingWindowSize.truncatingRemainder(dividingBy: 3600 * 24) == 0 {
                        self.selectedDateComponentIndex = 2
                        self.rollingWindowSize = insightDefinitionRequestBody.rollingWindowSize / -3600 / 24
                    } else if insightDefinitionRequestBody.rollingWindowSize.truncatingRemainder(dividingBy: 3600) == 0 {
                        selectedDateComponentIndex = 1
                        self.rollingWindowSize = insightDefinitionRequestBody.rollingWindowSize / -3600
                    } else {
                        selectedDateComponentIndex = 0
                        self.rollingWindowSize = insightDefinitionRequestBody.rollingWindowSize * -1
                    }
            }
        
    }
}

//struct NewInsightForm_Previews: PreviewProvider {
//    static var platform: PreviewPlatform? = nil
//
//    static var previews: some View {
//        CreateOrUpdateInsightForm(app: MockData.app1, isPresented: .constant(true))
//            .environmentObject(APIRepresentative())
//            .previewLayout(.fixed(width: 600, height: 1000))
//    }
//}
