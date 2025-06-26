//
//  ContentView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import Combine
import SwiftUI

private enum MainTab: String, CaseIterable {
    case home = "house"
    case transactions = "dollarsign.ring.dashed"
    case cards = "creditcard"
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var messageService: MessageService
    
    @State private var selectedTab: MainTab = .home
    @StateObject private var keyboardResponder = KeyboardResponder()
    
    var body: some View {
        ZStack(alignment: .top) {
            TabView {
                Tab("", systemImage: MainTab.home.rawValue) {
                    HomeView()
                }
                
                Tab("", systemImage: MainTab.transactions.rawValue) {
                    TransactionListView()
                }
                
                Tab("", systemImage: MainTab.cards.rawValue) {
                    CardListView()
                }
            }
            
            VStack(alignment: .trailing) {
                if messageService.show {
                    MessageBannerView(
                        message: messageService.message,
                        type: messageService.type
                    )
                    .animation(.easeInOut(duration: 0.3), value: messageService.message)
                    .zIndex(1)
                    .offset(y: 35)
                }
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
