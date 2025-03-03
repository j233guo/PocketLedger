//
//  AddTransactionView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import SwiftData
import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @Query private var transactionCategories: [TransactionCategory]
    
    @State private var transactionType: TransactionType
    @State private var amount: Double = 0.0
    @State private var date: Date = .now
    @State private var paymentType: PaymentType = .cash
    @State private var notes = ""
    @State private var transactionCategory: TransactionCategory?
    @State private var showCategoryEmptyWarning = false
    @State private var showAmountEmptyWarning = false
    
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
        guard !showAmountEmptyWarning && !showCategoryEmptyWarning else {
            return
        }
        let newTransaction = Transaction(
            transactionType: transactionType,
            amount: amount,
            date: date,
            paymentType: paymentType,
            category: transactionCategory
        )
        modelContext.insert(newTransaction)
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
                
                Section("Date") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
                
                if transactionType == .expense {
                    Picker("Payment Type", selection: $paymentType) {
                        Label("Cash", systemImage: "banknote")
                            .tag(PaymentType.cash)
                        Label("Debit", systemImage: "creditcard.and.123")
                            .tag(PaymentType.debit)
                        Label("Credit Card", systemImage: "creditcard")
                            .tag(PaymentType.credit)
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
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
