//
//  TransactionDetailView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-06.
//

import SwiftUI

private struct TransactionInfoSection: View {
    let transaction: Transaction
    
    var body: some View {
        Section {
            VStack(alignment: .center) {
                let sign = transaction.transactionType == .expense ? "-" : "+"
                    Text("\(sign)\(formatCurrency(double: transaction.amount))")
                        .font(.largeTitle)
                        .bold()
                        .fontDesign(.monospaced)
                        .padding()
                    
                    if let category = transaction.category {
                        HStack {
                            Image(systemName: category.icon)
                            Text(category.displayName)
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text(String(localized: "Uncategorized Transaction", table: "TransactionDetail"))
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(transaction.date.formatted(date: .long, time: .omitted))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
        }
    }

private struct PaymentInfoSection: View {
    let transaction: Transaction
    
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                if let card = transaction.card {
                    Text(transaction.paymentType?.localizedString ?? "")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack {
                        Text("\(card.name)")
                        Spacer()
                        Text("••••\(card.lastFourDigits)")
                            .fontDesign(.monospaced)
                    }
                    .font(.headline)
                    .padding(.vertical, 5)
                    
                    if transaction.paymentType == .credit {
                        let rewardAmount = calculateReward(card: card, transaction: transaction)
                        if rewardAmount.isZero || rewardAmount.isNaN {
                            Text(String(localized: "You did not earn any reward from this transaction.", table: "TransactionDetail"))
                                .foregroundStyle(.secondary)
                        } else {
                            if card.perkType == .points {
                                let formattedRewardAmount = rewardAmount.decimalStr(2)
                                Text(String(localized: "You earned \(formattedRewardAmount) points from this transaction.", table: "TransactionDetail"))
                                    .foregroundStyle(.secondary)
                            } else if card.perkType == .cashback {
                                let formattedRewardAmount = formatCurrency(string: rewardAmount.decimalStr(2))
                                Text(String(localized: "You earned \(formattedRewardAmount) cash back from this transaction.", table: "TransactionDetail"))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        } header: {
            Text(String(localized: "Payment Card", table: "TransactionDetail"))
        } footer: {
            if transaction.paymentType == .credit {
                Text(String(localized: "Credit card rewards are estimations only. Actual values may vary.", table: "TransactionDetail"))
            }
        }
    }
}

struct TransactionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @EnvironmentObject private var messageService: MessageService
    
    @State private var showEditTransactionView = false
    @State private var showDeleteConfirmation = false
    
    var transaction: Transaction
    
    func deleteTransaction() {
        modelContext.delete(transaction)
        do {
            try modelContext.save()
            messageService.create(
                message: String(localized: "Transaction deleted successfully", table: "Message"),
                type: .success
            )
            dismiss()
        } catch {
            messageService.create(
                message: String(localized: "Error saving data: \(error.localizedDescription)"),
                type: .error
            )
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                TransactionInfoSection(transaction: transaction)
                
                if transaction.transactionType == .expense && transaction.paymentType != .cash {
                    PaymentInfoSection(transaction: transaction)
                }
                
                if let note = transaction.note {
                    if !note.isEmpty {
                        Section(String(localized: "Notes", table: "TransactionDetail")) {
                            Text(note)
                        }
                    }
                }
                
                Section {
                    Button(String(localized: "Edit Transaction", table: "TransactionDetail")) {
                        showEditTransactionView = true
                    }
                    Button(String(localized: "Delete Transaction", table: "TransactionDetail"), role: .destructive) {
                        showDeleteConfirmation = true
                    }
                }
            }
            .navigationTitle(String(localized: "Transaction Details", table: "TransactionDetail"))
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showEditTransactionView) {
                EditTransactionView(transaction: transaction)
            }
            .confirmationDialog(String(localized: "Delete Transaction", table: "TransactionDetail"), isPresented: $showDeleteConfirmation) {
                Button(String(localized: "Confirm Delete", table: "TransactionDetail"), role: .destructive, action: deleteTransaction)
            } message: {
                Text(String(localized: "This transaction will be gone forever.", table: "TransactionDetail"))
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
        index: 0,
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
