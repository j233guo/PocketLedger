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
                .fontDesign(.monospaced)
                .foregroundStyle(transaction.transactionType == .expense ? .primary : Color.green)
        }
        .padding(5)
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

struct TransactionListToolbarView: View {
    @Binding var filterExpanded: Bool
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    var withFilter: Bool
    var withAdd: Bool
    var onAddTransaction: () -> Void = {}
    
    var body: some View {
        VStack {
            HStack {
                if withFilter {
                    Button {
                        withAnimation {
                            filterExpanded.toggle()
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                
                if withAdd {
                    Button {
                        onAddTransaction()
                    } label: {
                        Label("Add Transaction", systemImage: "plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .frame(maxWidth: .infinity)
            
            if filterExpanded {
                HStack(alignment: .center) {
                    Text("Date Range")
                        .foregroundStyle(.secondary)
                    DateFilterView(startDate: $startDate, endDate: $endDate)
                }
                .padding(.vertical,5)
            }
            Divider()
        }
        .padding(.horizontal)
        .background(Color(.systemGroupedBackground))
    }
}

struct TransactionListEmptyView: View {
    var message: String
    
    var body: some View {
        VStack {
            Text("Empty Transaction List")
                .font(.title)
            Text(message)
                .font(.footnote)
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

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
    let expenseCategory = TransactionCategory(
        name: "Dining",
        transactionType: .expense,
        isCustom: false,
        index: 1,
        icon: "fork.knife"
    )
    let incomeCategory = TransactionCategory(
        name: "Payroll",
        transactionType: .income,
        isCustom: false,
        index: 0,
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
    if let container = createPreviewModelContainer() {
        container.mainContext.insert(expenseTransaction)
        container.mainContext.insert(incomeTransaction)
        return TransactionListView()
            .modelContainer(container)
    } else {
        return TransactionListView()
    }
}
