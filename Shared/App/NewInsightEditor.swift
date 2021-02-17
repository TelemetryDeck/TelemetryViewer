//
//  NewInsightEditor.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 17.02.21.
//

import SwiftUI

struct NewInsightEditor: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var api: APIRepresentative
    let app: TelemetryApp
    let insightGroup: InsightGroup
    let insight: Insight

    var body: some View {
        let form = Form {
            CustomSection(header: Text("Meta Information"), summary: EmptyView(), footer: EmptyView(), startCollapsed: true) {
//                if let dto = viewModel.insightDTO {
//                    Group {
//                        Text("This Insight was last updated ")
//                            + Text(dto.calculatedAt, style: .relative).bold()
//                            + Text(" ago. The server needed ")
//                            + Text("\(dto.calculationDuration) seconds").bold()
//                            + Text(" to calculate it.")
//                    }
//                    .opacity(0.4)
//                    .padding(.vertical, 2)
//
//                    Group {
//                        Text("The Insight will automatically be updated once it's ")
//                            + Text("5 Minutes").bold()
//                            + Text(" old.")
//                    }
//                    .opacity(0.4)
//                    .padding(.bottom, 4)
//                }

                if insight.shouldUseDruid {
                    Text("This Insight's data is calculated using Druid 🧙‍♂️")
                        .bold()
                        .opacity(0.4)
                        .padding(.bottom, 4)
                }

                Button("Copy Insight ID") {
                    saveToClipBoard(insight.id.uuidString)
                }
                .buttonStyle(SmallSecondaryButtonStyle())
            }

            CustomSection(header: Text("Delete"), summary: EmptyView(), footer: EmptyView(), startCollapsed: true) {
                Button("Delete this Insight", action: {
                    api.delete(insight: insight, in: insightGroup, in: app) { _ in
                        self.presentation.wrappedValue.dismiss()
                    }
                })
                    .buttonStyle(SmallSecondaryButtonStyle())
                    .accentColor(.red)
            }
        }
        .navigationTitle("Edit Insight")

        #if os(macOS)
        ScrollView {
            form
                .padding()
        }
        #else
        form
        #endif
    }
}
