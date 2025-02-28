//
//  ContentView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedTab = "dashboard"
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.xaxis")
                }
                .tag("dashboard")
            TransactionListView()
                .tabItem {
                    Label("Transactions", systemImage: "dollarsign.ring.dashed")
                }
                .tag("transactions")
            CardListView()
                .tabItem {
                    Label("Cards", systemImage: "creditcard.fill")
                }
                .tag("cards")
        }
        .onAppear {
            DefaultTransactionCategoryFactory.createDefaultCategories(modelContext: modelContext)
        }
    }
}

#Preview {
    ContentView()
}
