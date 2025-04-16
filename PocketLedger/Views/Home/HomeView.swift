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
                        HStack {
                            Image(systemName: "plus")
                            Text(String(localized: "Log New Transaction", table: "Home"))
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle)
                    .foregroundStyle(.primary)
                }
                .padding(.vertical)
                
                MonthlySummaryView()
                    .padding(.vertical)
                
                MonthlyBudgetView()
                    .padding(.vertical)
            }
            .listStyle(.plain)
            .contentMargins(.bottom, 100)
            .navigationTitle(String(localized: "Home", table: "Home"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
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
