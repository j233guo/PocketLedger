//
//  CardListView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import SwiftData
import SwiftUI

fileprivate struct CardListRowView: View {
    let card: Card
    
    var body: some View {
        HStack {
            CardLogoView(network: card.paymentNetwork, size: 40.0)
                .padding(5)
            Text(card.name)
            Spacer()
            Text("••••\(card.lastFourDigits)")
        }
    }
}

struct CardListView: View {
    @State private var showAddCardView = false
    
    @Query private var cards: [Card]
    
    var body: some View {
        NavigationStack {
            Group {
                if cards.isEmpty {
                    VStack {
                        Text("Empty Card List")
                            .font(.title)
                        Text("Tap \"+\" to add cards")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                } else {
                    List {
                        ForEach(cards) { card in
                            NavigationLink {
                                CardDetailView(card: card)
                            } label: {
                                CardListRowView(card: card)
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Cards")
            .toolbar {
                ToolbarItem {
                    Button("Add Card", systemImage: "plus") {
                        showAddCardView = true
                    }
                }
            }
            .sheet(isPresented: $showAddCardView) {
                AddCardView()
            }
        }
    }
}

#Preview {
    if let container = createPreviewModelContainer() {
        CardListView()
            .modelContainer(container)
    } else {
        CardListView()
    }
}
