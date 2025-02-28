//
//  TransactionsView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import SwiftData
import SwiftUI

struct TransactionListRowView: View {
    var transaction: Transaction
    
    var body: some View {
        HStack {
            Image(systemName: transaction.category?.icon ?? "")
            Text(transaction.category?.name ?? "")
                .font(.headline)
            Spacer()
            let sign = transaction.transactionType == .expense ? "-" : "+"
            Text("\(sign)\(formatCurrency(transaction.amount))")
                .font(.headline)
                .foregroundStyle(transaction.transactionType == .expense ? .primary : Color.green)
        }
    }
}

struct TransactionListView: View {
    @State private var showAddTransactionView: Bool = false
    
    @Query private var transactions: [Transaction]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(transactions) { transaction in
                    TransactionListRowView(transaction: transaction)
                }
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add", systemImage: "plus.circle") {
                        showAddTransactionView = true
                    }
                }
            }
            .sheet(isPresented: $showAddTransactionView) {
                AddTransactionView()
            }
        }
    }
}

#Preview {
    if let container = createPreviewModelContainer() {
        TransactionListView()
            .modelContainer(container)
    } else {
        TransactionListView()
    }
}
