//
//  AddTransactionView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import SwiftData
import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
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
    
    @State private var transactionType: TransactionType
    @State private var amount: Double = 0.0
    @State private var date: Date = .now
    @State private var paymentType: PaymentType = .cash
    @State private var note = ""
    @State private var transactionCategory: TransactionCategory?
    @State private var card: Card? = nil
    @State private var showCategoryEmptyWarning = false
    @State private var showAmountEmptyWarning = false
    @State private var showCardEmptyWarning = false
    
    @FocusState private var amountInputFocused: Bool
    @FocusState private var notesInputFocused: Bool
    
    init() {
        _transactionType = State(initialValue: .expense)
        let predicate = #Predicate<TransactionCategory> {
            $0.transactionType == transactionType
        }
        _transactionCategories = Query(filter: predicate)
    }
    
    func save() {
        if transactionCategory == nil {
            showCategoryEmptyWarning = true
        }
        if amount == 0 {
            showAmountEmptyWarning = true
        }
        if paymentType != .cash && card == nil {
            showCardEmptyWarning = true
        }
        guard !showAmountEmptyWarning && !showCategoryEmptyWarning && !showCardEmptyWarning else {
            return
        }
        if transactionType == .income {
            let newTransaction = Transaction(
                transactionType: transactionType,
                amount: amount,
                date: date,
                category: transactionCategory,
                note: note
            )
            modelContext.insert(newTransaction)
        } else if transactionType == .expense {
            if paymentType == .cash {
                let newTransaction = Transaction(
                    transactionType: transactionType,
                    amount: amount,
                    date: date,
                    category: transactionCategory,
                    paymentType: paymentType,
                    note: note
                )
                modelContext.insert(newTransaction)
            } else {
                let newTransaction = Transaction(
                    transactionType: transactionType,
                    amount: amount,
                    date: date,
                    category: transactionCategory,
                    paymentType: paymentType,
                    card: card,
                    note: note
                )
                modelContext.insert(newTransaction)
            }
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
                    transactionCategory = nil
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
                            card = nil
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
            .navigationTitle("Add a New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        save()
                    } label: {
                        Text("Save")
                            .bold()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button {
                            amountInputFocused = false
                            notesInputFocused = false
                        } label: {
                            Text("Done")
                                .bold()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    AddTransactionView()
}
