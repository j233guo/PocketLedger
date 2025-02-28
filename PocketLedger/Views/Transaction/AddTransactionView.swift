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
    
    @State private var transactionType: TransactionType = .expense
    @State private var amount: Double = 0.0
    @State private var date: Date = .now
    @State private var paymentType: PaymentType = .cash
    @State private var notes = ""
    
    @FocusState private var amountInputFocused: Bool
    @FocusState private var notesInputFocused: Bool
    
    func save() {
        let newTransaction = Transaction(
            transactionType: transactionType,
            amount: amount,
            date: date
        )
        modelContext.insert(newTransaction)
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Transaction Type", selection: $transactionType) {
                    Text("Expense")
                        .tag(TransactionType.expense)
                    Text("Income")
                        .tag(TransactionType.income)
                }
                .pickerStyle(.palette)
                
                Section("Amount") {
                    TextField("Amount", value: $amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .focused($amountInputFocused)
                        .keyboardType(.decimalPad)
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
