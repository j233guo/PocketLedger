//
//  CardListView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import SwiftData
import SwiftUI

private struct CardListRowView: View {
    let card: Card
    
    var body: some View {
        HStack {
            CardLogoView(network: card.paymentNetwork, size: 40.0)
                .padding(5)
            Text(card.name)
                .font(.headline)
            Spacer()
            Text("••••\(card.lastFourDigits)")
                .fontWeight(.medium)
                .fontDesign(.monospaced)
        }
    }
}

struct CardListView: View {
    @State private var showAddCardView = false
    
    @Query private var cards: [Card]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                if cards.isEmpty {
                    VStack {
                        Text(String(localized: "Empty Card List", table: "CardList"))
                            .font(.title)
                        Text(String(localized: "Tap \"Add Card\" button to add your first card.", table: "CardList"))
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    .listStyle(.insetGrouped)
                    .contentMargins(.bottom, 100)
                }
                
                HStack {
                    Spacer()
                    Button {
                        showAddCardView = true
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                                .fontWeight(.bold)
                            Text(String(localized: "Add Card", table: "CardList"))
                                .fontWeight(.bold)
                        }
                        .padding(5)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .offset(x: -20, y: -20)
                }
            }
            .navigationTitle(String(localized: "My Cards", table: "CardList"))
            .sheet(isPresented: $showAddCardView) {
                AddCardView()
            }
        }
    }
}

#Preview {
    if let container = createPreviewModelContainer() {
        let card = Card(
            name: "My Credit Card",
            cardType: .credit,
            paymentNetwork: .amex,
            lastFourDigits: "1000",
            perkType: .points
        )
        container.mainContext.insert(card)
        return CardListView()
            .modelContainer(container)
    } else {
        return CardListView()
    }
}
