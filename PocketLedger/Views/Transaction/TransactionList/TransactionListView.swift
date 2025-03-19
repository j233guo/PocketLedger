//
//  TransactionsView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import SwiftData
import SwiftUI

struct TransactionListView: View {
    @State private var showAddTransactionView: Bool = false
    @State private var filterExpanded: Bool = false
    @State private var startDate = Calendar.current.startOfDay(for: .now.addingTimeInterval(-30*24*3600))
    @State private var endDate = Calendar.current.startOfDay(for: .now)
    
    @Query(
        sort: \Transaction.date, order: .reverse
    ) private var transactions: [Transaction]
    
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
                // TODO: replace with interactive alert banner
                print("Error when filtering transaction: \(error.localizedDescription)")
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
                    withFilter: !transactions.isEmpty,
                    withAdd: true
                ) {
                    showAddTransactionView = true
                }
                if transactions.isEmpty {
                    TransactionListEmptyView(message: "Tap \"Add Transaction\" to log your first transaction.")
                } else {
                    if filteredTransactions.isEmpty {
                        TransactionListEmptyView(message: "No transactions found based on your filter.")
                    } else {
                        GroupedTransactionListView(transactions: filteredTransactions)
                    }
                }
            }
            .navigationTitle("Transactions")
            .sheet(isPresented: $showAddTransactionView) {
                AddTransactionView()
            }
            .animation(.easeInOut, value: filteredTransactions)
        }
    }
}

#Preview {
    let expenseTransaction = DefaultTransactionFactory.expenseExample
    let incomeTransaction = DefaultTransactionFactory.incomeExample
    if let container = createPreviewModelContainer() {
        container.mainContext.insert(expenseTransaction)
        container.mainContext.insert(incomeTransaction)
        return TransactionListView()
            .modelContainer(container)
    } else {
        return TransactionListView()
    }
}
