//
//  TransactionsView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import SwiftData
import SwiftUI

struct TransactionListView: View {
    @EnvironmentObject private var messageService: MessageService
    
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
                messageService.create(
                    message: String(localized: "Error filtering transactions: \(error.localizedDescription)", table: "Message"),
                    type: .error
                )
                return []
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    HStack(alignment: .center) {
                        Text(String(localized: "Date", table: "TransactionList"))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        DateFilterView(startDate: $startDate, endDate: $endDate)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical,5)
                    .padding(.horizontal)
                    .background(Color(.systemGroupedBackground))
                    
                    Divider()
                    
                    if transactions.isEmpty {
                        TransactionListEmptyView(
                            message: String(localized: "Tap \"Log Transaction\" to log your first transaction.", table: "TransactionList")
                        )
                    } else {
                        if filteredTransactions.isEmpty {
                            TransactionListEmptyView(
                                message: String(localized: "No transactions found based on your filter.", table: "TransactionList")
                            )
                        } else {
                            GroupedTransactionListView(transactions: filteredTransactions)
                        }
                    }
                }
                
                HStack {
                    Spacer()
                    Button {
                        showAddTransactionView = true
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                                .fontWeight(.bold)
                            Text(String(localized: "Log Transaction", table: "TransactionList"))
                                .multilineTextAlignment(.center)
                                .fontWeight(.semibold)
                        }
                        .padding(5)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .offset(x: -20, y: -20)
                }
            }
            .navigationTitle(String(localized: "Transactions", table: "TransactionList"))
            .sheet(isPresented: $showAddTransactionView) {
                AddTransactionView()
            }
            .animation(.easeInOut, value: filteredTransactions)
        }
    }
}

#Preview {
    if let container = createPreviewModelContainer() {
        container.mainContext.insert(DefaultTransactionFactory.expenseExample)
        container.mainContext.insert(DefaultTransactionFactory.incomeExample)
        return TransactionListView()
            .modelContainer(container)
    } else {
        return TransactionListView()
    }
}
