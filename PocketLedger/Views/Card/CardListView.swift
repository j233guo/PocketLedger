//
//  CardListView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import SwiftData
import SwiftUI

struct CardListView: View {
    @State private var showAddCardView = false
    
    @Query private var cards: [Card]
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(cards) { card in
                        HStack {
                            CardLogoView(network: card.paymentNetwork, size: 40.0)
                                .padding(5)
                            Text(card.name)
                            Spacer()
                            Text("••••\(card.lastFourDigits)")
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
                
                if cards.isEmpty {
                    VStack {
                        Text("No Cards")
                            .font(.title)
                        Text("Tap \"+\" to add cards")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
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
