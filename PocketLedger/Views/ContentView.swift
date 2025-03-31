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
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Image(systemName: "house")
                    }
                    .tag("home")
                TransactionListView()
                    .tabItem {
                        Image(systemName: "dollarsign.ring.dashed")
                    }
                    .tag("transactions")
                CardListView()
                    .tabItem {
                        Image(systemName: "creditcard")
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
                .offset(y: -65)
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
