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
            VStack(spacing: 0) {
                VStack {
                    HStack {
                        Button {
                            showAddCardView = true
                        } label: {
                            Label(String(localized: "Add Card", table: "CardList"), systemImage: "plus")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity)
                    Divider()
                }
                .padding(.horizontal)
                .background(Color(.systemGroupedBackground))
                
                if cards.isEmpty {
                    VStack {
                        Text(String(localized: "Empty Card List", table: "CardList"))
                            .font(.title)
                        Text(String(localized: "Add a card with the button above", table: "CardList"))
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
