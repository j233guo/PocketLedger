//
//  ContentView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.xaxis")
                }
            TransactionListView()
                .tabItem {
                    Label("Transactions", systemImage: "dollarsign.ring.dashed")
                }
            CardListView()
                .tabItem {
                    Label("Cards", systemImage: "creditcard.fill")
                }
        }
        .onAppear {
            
        }
    }
}

#Preview {
    ContentView()
}
