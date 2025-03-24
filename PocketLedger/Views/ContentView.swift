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
    
    @State private var selectedTab = "home"
    
    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label(String(localized: "Home", table: "Common"), systemImage: "house")
                    }
                    .tag("home")
                TransactionListView()
                    .tabItem {
                        Label(String(localized: "Transactions", table:"Common"), systemImage: "dollarsign.ring.dashed")
                    }
                    .tag("transactions")
                CardListView()
                    .tabItem {
                        Label(String(localized: "Cards", table: "Common"), systemImage: "creditcard")
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
        .environmentObject(MessageService())
}
