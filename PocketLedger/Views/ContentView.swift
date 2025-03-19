//
//  ContentView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @EnvironmentObject var messageService: MessageService
    
    @State private var selectedTab = "dashboard"
    
    var body: some View {
        ZStack(alignment: .top) {
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
            
            if messageService.show {
                MessageBannerView(
                    message: messageService.message,
                    type: messageService.type
                )
                .animation(.easeInOut(duration: 0.3), value: messageService.message)
                .zIndex(1)
            }
        }
        .onAppear {
            DefaultTransactionCategoryFactory.createDefaultCategories(modelContext: modelContext)
        }
    }
}

#Preview {
    ContentView()
}
