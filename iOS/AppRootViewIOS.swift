//
//  AppRootView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 17.02.21.
//

import SwiftUI

struct AppRootView: View {
    @Environment(\.presentationMode) var presentationMode

    @EnvironmentObject var appService: OldAppService
    @EnvironmentObject var insightService: OldInsightService
    @EnvironmentObject var insightCalculationService: InsightCalculationService

    @State private var showDatePicker: Bool = false
    @State private var newInsightGroupID: UUID?

    let appID: UUID

    var insightList: some View {
        List {
            ForEach(insightService.insightGroups(for: appID) ?? []) { insightGroup in
                Section(header: Text(insightGroup.title)) {
                    let sortedInsights = insightGroup.insights.sorted {
                        $0.order ?? 0 < $1.order ?? 0
                    }

                    InsightList(appID: appID, insightGroupID: insightGroup.id, insights: sortedInsights)

                    newInsightButton(insightGroup: insightGroup)
                    editInsightGroupButton(insightGroup: insightGroup)
                }
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            insightList
                .navigationBarTitle(appService.getSelectedApp()?.name ?? "–")
                .navigationBarItems(trailing: EditButton())

            if (insightService.insightGroups(for: appID) ?? []).isEmpty {
                EmptyAppView(appID: appID)
                    .padding()
            }

            if showDatePicker {
                datePickerBackground()
                datePicker()
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button(insightCalculationService.timeIntervalDescription) {
                    withAnimation {
                        self.showDatePicker.toggle()
                    }
                }

                Spacer()

                Button {
                    insightService.create(insightGroupNamed: "New Insight Group", for: appID)
                } label: {
                    Text("New Insight Group") // , systemImage: "plus")
                }
            }
        }
    }

    func newInsight(_ definitionRequestBody: InsightDefinitionRequestBody, appID: UUID) {
        guard let groupID = definitionRequestBody.groupID else { return }
        insightService.create(insightWith: definitionRequestBody, in: groupID, for: appID) { _ in
            presentationMode.wrappedValue.dismiss()
        }
    }

    func datePickerBackground() -> some View {
        Rectangle()
            .fill(Color.grayColor.opacity(0.4))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .onTapGesture {
                withAnimation {
                    showDatePicker.toggle()
                }
            }
    }

    func datePicker() -> some View {
        CardView {
            InsightDataTimeIntervalPickerForCalculationService()
                .padding()
        }
        .frame(maxHeight: 200)
        .padding()
        .transition(.move(edge: .bottom))
    }

    func editInsightGroupButton(insightGroup: DTO.InsightGroup) -> some View {
        NavigationLink(destination: InsightGroupEditor(appID: appID, insightGroup: insightGroup)) {
            Label("Edit \(insightGroup.title)", systemImage: "pencil")
        }
    }

    func newInsightButton(insightGroup: DTO.InsightGroup) -> some View {
        Button {
            newInsightGroupID = insightGroup.id
        } label: {
            Label("New Insight in \(insightGroup.title)", systemImage: "plus")
        }
        .actionSheet(item: $newInsightGroupID) { newInsightGroupID in
            ActionSheet(
                title: Text("New Insight"),
                message: Text("Please select one of these template insights to get started"),
                buttons: [
                    .cancel { self.newInsightGroupID = nil },
                    .default(Text("Generic Time Series Insight")) { newInsight(.newTimeSeriesInsight(groupID: newInsightGroupID), appID: appID) },
                    .default(Text("Generic Breakdown Insight")) { newInsight(.newBreakdownInsight(groupID: newInsightGroupID), appID: appID) },

                    .default(Text("Daily Active Users")) { newInsight(.newDailyUserCountInsight(groupID: newInsightGroupID), appID: appID) },
                    .default(Text("Weekly Active Users")) { newInsight(.newDailyUserCountInsight(groupID: newInsightGroupID), appID: appID) },
                    .default(Text("Monthly Active Users")) { newInsight(.newMonthlyUserCountInsight(groupID: newInsightGroupID), appID: appID) },
                    .default(Text("Daily Signals")) { newInsight(.newSignalInsight(groupID: newInsightGroupID), appID: appID) },

                    .default(Text("App Versions Breakdown")) { newInsight(.newBreakdownInsight(groupID: newInsightGroupID, title: "App Versions Breakdown", breakdownKey: "appVersion"), appID: appID) },
                    .default(Text("Build Number Breakdown")) { newInsight(.newBreakdownInsight(groupID: newInsightGroupID, title: "Build Number Breakdown", breakdownKey: "buildNumber"), appID: appID) },
                    .default(Text("Device Type Breakdown")) { newInsight(.newBreakdownInsight(groupID: newInsightGroupID, title: "Device Type Breakdown", breakdownKey: "modelName"), appID: appID) },
                    .default(Text("OS Breakdown")) { newInsight(.newBreakdownInsight(groupID: newInsightGroupID, title: "OS Breakdown", breakdownKey: "systemVersion"), appID: appID) }
                ]
            )
        }
    }
}

struct InsightList: View {
    @Environment(\.editMode) var isEditMode
    @EnvironmentObject var insightService: OldInsightService
    @EnvironmentObject var insightCalculationService: InsightCalculationService

    @State var showEditorSheet: Bool = false
    @State var editedInsightID: UUID?

    let appID: UUID
    let insightGroupID: UUID

    @State var insights: [DTO.InsightDTO]

    var body: some View {
        ForEach(insights) { data in
            HStack {
                InsightView(topSelectedInsightID: .constant(nil), appID: appID, insightGroupID: insightGroupID, insightID: data.id)
                    .buttonStyle(CardButtonStyle(isSelected: false))

                if isEditMode?.wrappedValue == .active {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.accentColor)
                        .onTapGesture {
                            editedInsightID = data.id
                        }
                        .sheet(item: $editedInsightID) {
                            editedInsightID = nil
                        } content: { item in
                            VStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.grayColor.opacity(0.3))
                                    .frame(width: 60, height: 10)
                                    .padding()

                                NavigationView {
                                    insightService.insight(id: item, in: insightGroupID, in: appID).map {
                                        InsightEditor(editorContent: InsightEditorContent.from(insight: $0), appID: appID, insightGroupID: insightGroupID)
                                            .navigationBarTitleDisplayMode(.inline)
                                    }
                                }
                                .padding(.top, -20)
                            }
                            // in iOS 14, sheets do not get passed the environment by default. Passing them manually here
                            .environmentObject(insightService)
                            .environmentObject(insightCalculationService)
                        }
                }
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
        }
        .onMove(perform: move)
        .onDelete(perform: delete)
    }

    private func delete(at offsets: IndexSet) {
        for offset in offsets {
            let data = insights[offset]
            insights.remove(atOffsets: offsets)

            insightService.delete(insightID: data.id, in: insightGroupID, in: appID)
        }
    }

    private func move(source: IndexSet, destination: Int) {
        insights.move(fromOffsets: source, toOffset: destination)

        for (order, insight) in insights.enumerated() {
            let requestBody = InsightDefinitionRequestBody(
                order: Double(order),
                title: insight.title,
                subtitle: insight.subtitle,
                signalType: insight.signalType,
                uniqueUser: insight.uniqueUser,
                filters: insight.filters,
                rollingWindowSize: insight.rollingWindowSize,
                breakdownKey: insight.breakdownKey,
                groupBy: insight.groupBy,
                displayMode: insight.displayMode,
                groupID: insight.group.first?.value ?? UUID(),
                id: insight.id,
                isExpanded: insight.isExpanded,
                shouldUseDruid: insight.shouldUseDruid
            )

            insightService.update(insightID: insight.id, in: insightGroupID, in: appID, with: requestBody)
        }
    }
}

extension UUID: Identifiable {
    public var id: UUID { return self }
}
