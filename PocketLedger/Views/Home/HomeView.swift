//
//  HomeView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import SwiftUI

struct HomeView: View {
    @State private var showSettingsView: Bool = false
    @State private var showAddTransactionView: Bool = false
    
    var body: some View {
        NavigationStack{
            List {
                VStack(alignment: .leading) {
                    Text(String(localized: "Commonly Used", table: "Home"))
                        .font(.headline)
                    Button {
                        showAddTransactionView = true
                    } label: {
                        Text(String(localized: "Log Transaction", table: "Home"))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.vertical)
                
                MonthlySummaryView()
                    .padding(.vertical)
            }
            .listStyle(.plain)
            .navigationTitle(String(localized: "Home", table: "Home"))
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
    HomeView()
}
