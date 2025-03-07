//
//  EditTransactionView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-06.
//

import SwiftData
import SwiftUI

struct EditTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Query private var transactionCategories: [TransactionCategory]
    @Query(
        filter: #Predicate<Card> { card in
            card.cardTypeRawValue == "Debit"
        }
    ) private var debitCards: [Card]
    @Query(
        filter: #Predicate<Card> { card in
            card.cardTypeRawValue == "Credit"
        }
    ) private var creditCards: [Card]
    
    @State private var transactionType: TransactionType = .expense
    @State private var amount: Double = 0.0
    @State private var date: Date = .now
    @State private var paymentType: PaymentType? = nil
    @State private var note = ""
    @State private var transactionCategory: TransactionCategory? = nil
    @State private var card: Card? = nil
    @State private var showCategoryEmptyWarning = false
    @State private var showAmountEmptyWarning = false
    @State private var showCardEmptyWarning = false
    
    @FocusState private var amountInputFocused: Bool
    @FocusState private var notesInputFocused: Bool
    
    var transaction: Transaction
    
    func save() {
        if transactionCategory == nil {
            showCategoryEmptyWarning = true
        }
        if amount == 0 {
            showAmountEmptyWarning = true
        }
        if transactionType == .expense && paymentType != .cash && card == nil {
            showCardEmptyWarning = true
        }
        guard !showAmountEmptyWarning && !showCategoryEmptyWarning && !showCardEmptyWarning else {
            return
        }
        transaction.transactionType = transactionType
        transaction.amount = amount
        transaction.date = date
        transaction.note = note
        transaction.category = transactionCategory
        if transactionType == .expense {
            transaction.paymentType = paymentType!
            if paymentType != .cash {
                transaction.card = card!
            }
        } else {
            transaction.paymentType = nil
            transaction.card = nil
        }
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Transaction Type", selection: $transactionType) {
                        Text("Expense")
                            .tag(TransactionType.expense)
                        Text("Income")
                            .tag(TransactionType.income)
                    }
                    .pickerStyle(.palette)
                    CategoryPickerView(selectedCategory: $transactionCategory, transactionType: transactionType)
                } footer: {
                    if showCategoryEmptyWarning {
                        Text("Please select a category.")
                            .foregroundStyle(.red)
                    }
                }
                .onChange(of: transactionType) {
                    transactionCategory = transactionType == transaction.transactionType ? transaction.category : nil
                }
                .onChange(of: transactionCategory) {
                    showCategoryEmptyWarning = false
                }
                
                Section {
                    TextField("Amount", value: $amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .focused($amountInputFocused)
                        .keyboardType(.decimalPad)
                } header: {
                    Text("Amount")
                } footer: {
                    if showAmountEmptyWarning {
                        Text("Please enter a valid amount.")
                            .foregroundStyle(.red)
                    }
                }
                .onChange(of: amount) {
                    showAmountEmptyWarning = false
                }
                
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.compact)
                
                if transactionType == .expense {
                    Section {
                        Picker("Payment Type", selection: $paymentType) {
                            Label("Cash", systemImage: "banknote")
                                .tag(PaymentType.cash)
                            if !debitCards.isEmpty {
                                Label("Debit", systemImage: "creditcard.and.123")
                                    .tag(PaymentType.debit)
                            }
                            if !creditCards.isEmpty {
                                Label("Credit Card", systemImage: "creditcard")
                                    .tag(PaymentType.credit)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: paymentType) {
                            if paymentType == transaction.paymentType && paymentType != .cash {
                                card = transaction.card
                            } else {
                                card = nil
                            }
                            showCardEmptyWarning = false
                        }
                        
                        if paymentType != .cash {
                            Picker(paymentType == .debit ? "Debit Card" : "Credit Card", selection: $card) {
                                Text("Select a Card")
                                    .tag(nil as Card?)
                                if paymentType == .debit {
                                    ForEach(debitCards) { card in
                                        Text("\(card.name) ••••\(card.lastFourDigits)")
                                            .tag(card as Card?)
                                    }
                                } else if paymentType == .credit {
                                    ForEach(creditCards) { card in
                                        Text("\(card.name) ••••\(card.lastFourDigits)")
                                            .tag(card as Card?)
                                    }
                                }
                            }
                            .onChange(of: card) {
                                showCardEmptyWarning = false
                            }
                        }
                    } footer: {
                        if showCardEmptyWarning && paymentType != .cash {
                            Text("Please select a card.")
                                .foregroundStyle(.red)
                        }
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $note)
                        .focused($notesInputFocused)
                }
            }
            .navigationTitle("Edit Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                }
            }
            .onAppear {
                transactionType = transaction.transactionType
                amount = transaction.amount
                date = transaction.date
                paymentType = transaction.paymentType
                note = transaction.note ?? ""
                transactionCategory = transaction.category
                card = transaction.card
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
    EditTransactionView(transaction: transaction)
}
