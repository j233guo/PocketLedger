//
//  DashboardView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import SwiftUI

enum NavigationRoute {
    case setting
}

struct DashboardView: View {
    @State private var showSettingsView: Bool = false
    @State private var showAddTransactionView: Bool = false
    
    var body: some View {
        NavigationStack{
            List {
                Button {
                    showAddTransactionView = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Log a New Transaction")
                        Spacer()
                    }
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem {
                    Button("Settings", systemImage: "gearshape") {
                        showSettingsView = true
                    }
                }
            }
            .sheet(isPresented: $showAddTransactionView) {
                AddTransactionView()
            }
            .sheet(isPresented: $showSettingsView) {
                SettingsView()
            }
        }
    }
}

#Preview {
    DashboardView()
}
