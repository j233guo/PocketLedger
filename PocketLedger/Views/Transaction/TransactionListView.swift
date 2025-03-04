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
        .padding(5)
    }
}

#Preview {
    let expenseCategory = TransactionCategory(
        name: "Dining",
        icon: "fork.knife",
        isCustom: false,
        transactionType: .expense
    )
    let incomeCategory = TransactionCategory(
        name: "Payroll",
        icon: "dollarsign.circle",
        isCustom: false,
        transactionType: .income
    )
    let expenseTransaction = Transaction(
        transactionType: .expense,
        amount: 20.0,
        date: .now,
        paymentType: .cash,
        category: expenseCategory
    )
    let incomeTransaction = Transaction(
        transactionType: .income,
        amount: 100.0,
        date: .now,
        category: incomeCategory
    )
    List {
        TransactionListRowView(transaction: expenseTransaction)
        TransactionListRowView(transaction: incomeTransaction)
    }
}


struct TransactionListView: View {
    @State private var showAddTransactionView: Bool = false
    
    @Query private var transactions: [Transaction]
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(transactions) { transaction in
                        TransactionListRowView(transaction: transaction)
                    }
                }
                .navigationTitle("Transactions")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Add", systemImage: "plus") {
                            showAddTransactionView = true
                        }
                    }
                }
                .sheet(isPresented: $showAddTransactionView) {
                    AddTransactionView()
                }
                
                if transactions.isEmpty {
                    VStack {
                        Text("No Transactions")
                            .font(.title)
                        Text("Tap \"+\" to log a new transaction.")
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
        TransactionListView()
            .modelContainer(container)
    } else {
        TransactionListView()
    }
}
