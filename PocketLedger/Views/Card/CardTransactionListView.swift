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
    
    @EnvironmentObject private var messageService: MessageService
    
    @State private var filterExpanded = false
    @State private var startDate = Calendar.current.startOfDay(for: .now.addingTimeInterval(-30*24*3600))
    @State private var endDate = Calendar.current.startOfDay(for: .now)
    
    @Query(
        sort: \Transaction.date, order: .reverse
    ) private var transactions: [Transaction]
    
    let card: Card
    
    init(card: Card) {
        self.card = card
        let cardIDString = card.idString
        let predicate = #Predicate<Transaction> {
            $0.card?.idString == cardIDString
        }
        self._transactions = Query(filter: predicate)
    }
    
    private var transactionPredicate: Predicate<Transaction> {
        let adjustedEndDate = Calendar.current.date(byAdding: .day, value: 1, to: endDate)!
        return #Predicate<Transaction> {
            $0.date >= startDate && $0.date < adjustedEndDate
        }
    }
    
    private var filteredTransactions: [Transaction] {
        if !filterExpanded {
            return transactions
        } else {
            do {
                return try transactions.filter { transaction in
                    try transactionPredicate.evaluate(transaction)
                }
            } catch {
                messageService.create(
                    message: "Encountered error when filtering transaction on card: \(error.localizedDescription)",
                    type: .error
                )
                return []
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TransactionListToolbarView(
                    filterExpanded: $filterExpanded,
                    startDate: $startDate,
                    endDate: $endDate,
                    withFilter: true,
                    withAdd: false
                )
                if transactions.isEmpty {
                    TransactionListEmptyView(message: String(localized: "You do not have any transactions on this card.", table: "CardTransactionList"))
                } else {
                    if filteredTransactions.isEmpty {
                        TransactionListEmptyView(message: String(localized: "No transactions found based on your filter.", table: "CardTransactionList"))
                    } else {
                        GroupedTransactionListView(transactions: transactions)
                    }
                }
            }
            .navigationTitle(String(localized: "Transactions on Card", table: "CardTransactionList"))
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
