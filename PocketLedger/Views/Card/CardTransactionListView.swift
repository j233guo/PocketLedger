//
//  CardTransactionListView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-12.
//

import SwiftData
import SwiftUI

struct CardTransactionListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var transactions: [Transaction]
    
    let card: Card
    
    init(card: Card) {
        self.card = card
        let cardIDString = card.idString
        let predicate = #Predicate<Transaction> {
            $0.card?.idString == cardIDString
        }
        self._transactions = Query(filter: predicate)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if transactions.isEmpty {
                    VStack {
                        Text("Empty Transaction List")
                            .font(.title)
                        Text("Tap \"+\" to log a new transaction.")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                } else {
                    GroupedTransactionListView(transactions: transactions)
                }
            }
            .navigationTitle("Transactions on Card")
        }
    }
}

#Preview {
    let card = Card(
        name: "My Credit Card",
        cardType: .credit,
        paymentNetwork: .amex,
        lastFourDigits: "1000",
        perkType: .points
    )
    CardTransactionListView(card: card)
}
