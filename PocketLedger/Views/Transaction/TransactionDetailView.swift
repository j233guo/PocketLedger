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
                .frame(maxWidth: .infinity)
            }
        }
    }

    fileprivate struct PaymentInfoSection: View {
        let transaction: Transaction
        
        var body: some View {
            Section {
                VStack(alignment: .leading) {
                    if let card = transaction.card {
                        Text(transaction.paymentType == .debit ? "Debit Card" : "Credit Card")
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
                                Text("You did not earn any reward from this transaction.")
                                    .foregroundStyle(.secondary)
                            } else {
                                if card.perkType == .points {
                                    let formattedRewardAmount = rewardAmount.twoDecimalString()
                                    Text("You earned \(formattedRewardAmount) points from this transaction.")
                                        .foregroundStyle(.secondary)
                                } else if card.perkType == .cashback {
                                    let formattedRewardAmount = formatCurrency(string: rewardAmount.twoDecimalString())
                                    Text("You earned \(formattedRewardAmount) cash back from this transaction.")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            } header: {
                Text("Payment Card")
            } footer: {
                if transaction.paymentType == .credit {
                    Text("Credit card rewards are estimations only. Actual values may vary.")
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
                message: "Transaction deleted successfully",
                type: .success
            )
            dismiss()
        } catch {
            messageService.create(
                message: "Encountered error saving after deleting transaction: \(error.localizedDescription)",
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
                        Section("Notes") {
                            Text(note)
                        }
                    }
                }
                
                Section {
                    Button("Edit Transaction") {
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
                EditTransactionView(transaction: transaction)
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
