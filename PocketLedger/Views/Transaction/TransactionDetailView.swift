//
//  TransactionDetailView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-06.
//

import SwiftUI

fileprivate struct TransactionInfoSection: View {
    let transaction: Transaction
    
    var body: some View {
        VStack(alignment: .center) {
            let sign = transaction.transactionType == .expense ? "-" : "+"
            Text("\(sign)\(formatCurrency(transaction.amount))")
                .font(.system(size: 45))
                .bold()
                .fontDesign(.rounded)
                .padding()
            
            if let category = transaction.category {
                HStack {
                    Image(systemName: category.icon)
                    Text(category.name)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("Uncategorized Transaction")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            
            Text(transaction.date.formatted(date: .long, time: .omitted))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 2)
        }
        .padding()
    }
}

fileprivate struct PaymentInfoSection: View {
    let transaction: Transaction
    
    var body: some View {
        VStack {
            Group {
                if transaction.paymentType == .cash {
                    Text("Cash")
                } else if transaction.paymentType == .debit {
                    if let card = transaction.card {
                        Text("Debit Card \(card.name) ••••\(card.lastFourDigits)")
                    }
                } else if transaction.paymentType == .credit {
                    if let card = transaction.card {
                        Text("Credit Card \(card.name) ••••\(card.lastFourDigits)")
                    }
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

struct TransactionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var showEditTransactionView = false
    @State private var showDeleteConfirmation = false
    
    var transaction: Transaction
    
    func deleteTransaction() {
        modelContext.delete(transaction)
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack {
                        TransactionInfoSection(transaction: transaction)
                        
                        if transaction.transactionType == .expense {
                            Divider()
                            PaymentInfoSection(transaction: transaction)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                
                if let note = transaction.note {
                    if !note.isEmpty {
                        Section("Notes") {
                            Text(note)
                        }
                    }
                }
                
                Section {
                    Button("Edit") {
                        showEditTransactionView = true
                    }
                    Button("Delete This Transaction", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                }
            }
            .navigationTitle("Transaction Details")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showEditTransactionView) {
                EditTransactionView()
            }
            .confirmationDialog("Confirm Delete", isPresented: $showDeleteConfirmation) {
                Button("Confirm", role: .destructive, action: deleteTransaction)
            } message: {
                Text("This transaction will be gone forever.")
            }
        }
    }
}

#Preview {
    let card = Card(
        name: "My Amex Card",
        cardType: .credit,
        paymentNetwork: .amex,
        lastFourDigits: "0001"
    )
    let transactionCategory = TransactionCategory(
        name: "Shopping",
        transactionType: .expense,
        isCustom: false,
        icon: "bag.fill"
    )
    let transaction = Transaction(
        transactionType: .expense,
        amount: 100.0,
        date: .now,
        category: transactionCategory,
        paymentType: .credit,
        card: card,
        note: "lorem ipsum"
    )
    TransactionDetailView(transaction: transaction)
}
