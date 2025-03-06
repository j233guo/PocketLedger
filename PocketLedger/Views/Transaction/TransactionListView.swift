//
//  TransactionsView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import SwiftData
import SwiftUI

fileprivate struct TransactionListRowView: View {
    var transaction: Transaction
    
    var body: some View {
        HStack {
            CategoryLogoView(category: transaction.category, size: 25)
                .padding(.trailing, 10)
            Text(transaction.category?.name ?? "Uncategorized")
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
        transactionType: .expense,
        isCustom: false,
        icon: "fork.knife"
    )
    let incomeCategory = TransactionCategory(
        name: "Payroll",
        transactionType: .income,
        isCustom: false,
        icon: "dollarsign.circle"
    )
    let expenseTransaction = Transaction(
        transactionType: .expense,
        amount: 20.0,
        date: .now,
        category: expenseCategory,
        paymentType: .cash
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
                        NavigationLink(destination: TransactionDetailView(transaction: transaction)) {
                            TransactionListRowView(transaction: transaction)
                        }
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
