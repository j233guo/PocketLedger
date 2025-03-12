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
            CategoryLogoView(category: transaction.category, size: 20)
                .padding(.trailing, 10)
            Text(transaction.category?.name ?? "Uncategorized")
                .font(.headline)
            Spacer()
            let sign = transaction.transactionType == .expense ? "-" : "+"
            Text("\(sign)\(formatCurrency(double: transaction.amount))")
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

struct GroupedTransactionListView: View {
    var transactions: [Transaction]
    
    private let sectionDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    var body: some View {
        List {
            let groupedTransactions: [Date: [Transaction]] = Dictionary(grouping: transactions) { data in
                Calendar.current.startOfDay(for: data.date)
            }
            ForEach(groupedTransactions.keys.sorted { $0 > $1 }, id: \.self) { date in
                Section {
                    ForEach(groupedTransactions[date]!, id: \.id) { transaction in
                        NavigationLink {
                            TransactionDetailView(transaction: transaction)
                        } label: {
                            TransactionListRowView(transaction: transaction)
                        }
                    }
                } header: {
                    Text("\(date, formatter: sectionDateFormatter)")
                }
            }
        }
    }
}

struct TransactionListView: View {
    @State private var showAddTransactionView: Bool = false
    
    @Query private var transactions: [Transaction]
    
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
