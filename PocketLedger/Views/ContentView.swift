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

private struct TabButton: View {
    let tab: MainTab
    @Binding var selectedTab: MainTab
    
    var body: some View {
        Button {
            withAnimation(.easeIn(duration: 0.2)) {
                selectedTab = tab
            }
        } label: {
            Image(systemName: tab.rawValue)
                .symbolVariant(selectedTab == tab ? .fill : .none)
                .font(.system(size: 23))
                .scaleEffect(selectedTab == tab ? 1.25 : 1.0)
                .foregroundStyle(selectedTab == tab ? .primary : .secondary)
                .frame(width: 45, height: 45)
        }
        .buttonStyle(.plain)
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var messageService: MessageService
    
    @State private var selectedTab: MainTab = .home
    @StateObject private var keyboardResponder = KeyboardResponder()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                        .transition(.asymmetric(
                            insertion: .opacity,
                            removal: .move(edge: .leading).combined(with: .opacity)))
                case .transactions:
                    TransactionListView()
                        .transition(.asymmetric(
                            insertion: .opacity,
                            removal: .move(edge: .bottom).combined(with: .opacity)))
                case .cards:
                    CardListView()
                        .transition(.asymmetric(
                            insertion: .opacity,
                            removal: .move(edge: .trailing).combined(with: .opacity)))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack(alignment: .trailing) {
                if messageService.show {
                    MessageBannerView(
                        message: messageService.message,
                        type: messageService.type
                    )
                    .animation(.easeInOut(duration: 0.3), value: messageService.message)
                    .zIndex(1)
                    .offset(y: -5)
                }
                
                if !keyboardResponder.keyboardVisible {
                    HStack {
                        ForEach(MainTab.allCases, id: \.self) {
                            Spacer()
                            TabButton(tab: $0, selectedTab: $selectedTab)
                            Spacer()
                        }
                    }
                    .padding(.vertical, 10)
                    .background(.thinMaterial)
                    .shadow(radius: 2)
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
