//
//  TransactionListRowView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-19.
//

import SwiftUI

struct TransactionListRowView: View {
    var transaction: Transaction
    
    var body: some View {
        HStack {
            CategoryIconView(category: transaction.category, size: 20)
                .padding(.trailing, 10)
            Text(transaction.category?.displayName ?? String(localized: "Uncategorized", table: "Category"))
                .font(.headline)
            Spacer()
            let sign = transaction.transactionType == .expense ? "-" : "+"
            Text("\(sign)\(formatCurrency(double: transaction.amount))")
                .font(.headline)
                .fontDesign(.monospaced)
                .foregroundStyle(transaction.transactionType == .expense ? Color(hex: 0xB22222) : Color(hex: 0x006400))
        }
        .padding(5)
    }
}

#Preview {
    let expenseExample = DefaultTransactionFactory.expenseExample
    let incomeExample = DefaultTransactionFactory.incomeExample
    List {
        TransactionListRowView(transaction: expenseExample)
        TransactionListRowView(transaction: incomeExample)
    }
}
