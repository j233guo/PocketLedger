//
//  DashboardView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import SwiftUI

struct DashboardView: View {
    @State private var showSettingsView: Bool = false
    @State private var showAddTransactionView: Bool = false
    
    var body: some View {
        NavigationStack{
            List {
                VStack(alignment: .leading) {
                    Text("Commonly Used")
                        .font(.headline)
                    Button {
                        showAddTransactionView = true
                    } label: {
                        Text("Add a New Transaction")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.vertical)
                
                MonthlySummaryView()
                    .padding(.vertical)
            }
            .listStyle(.plain)
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
