//
//  GroupedTransactionListView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-19.
//

import SwiftUI

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

#Preview {
    let expenseTransaction = DefaultTransactionFactory.expenseExample
    let incomeTransaction = DefaultTransactionFactory.incomeExample
    GroupedTransactionListView(transactions: [expenseTransaction, incomeTransaction])
}
