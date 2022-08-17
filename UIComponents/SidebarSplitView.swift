//
//  SidebarSplitView.swift
//  SidebarSplitView
//
//  Created by Daniel Jilg on 05.08.21.
//
import SwiftUI

/// Split View that provides a main view, a side view, and automatic toolbar management for a toggle button
struct SidebarSplitView<MainView: View, SideView: View, MainToolbar: ToolbarContent>: View {
    let mainView: MainView
    let sideView: SideView
    let mainToolbar: MainToolbar

    @State var sidebarVisible: Bool = true

    init(@ViewBuilder content: () -> TupleView<(MainView, SideView)>, @ToolbarContentBuilder toolbar: () -> MainToolbar) {
        let views = content().value
        self.mainView = views.0
        self.sideView = views.1
        self.mainToolbar = toolbar()
    }

    private var sidebarToggleButton: some View {
        Button {
            sidebarVisible.toggle()

        } label: {
            Image(systemName: "sidebar.right")
        }
        .help("Toggle right right sidebar")
    }

    var body: some View {
        HSplitView {
            mainView
                .frame(minWidth: 100, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)

                .toolbar(content: {
                    mainToolbar

                    ToolbarItem {
                        if !sidebarVisible {
                            sidebarToggleButton
                        }
                    }
                })

            if sidebarVisible {
                ScrollView {
                    sideView
                }
//                .transition(.move(edge: .trailing))
                .background(Color.black.opacity(0.04))
                .frame(minWidth: 300, idealWidth: 300, minHeight: 100, maxHeight: .infinity)
                .toolbar {
                    ToolbarItemGroup {
                        Spacer()
                        sidebarToggleButton
                    }
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct SidebarSplitView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarSplitView {
            Text("Main")
            Text("Side")
        } toolbar: {
            ToolbarItem {
                Button("hello") {}
            }
        }
    }
}
