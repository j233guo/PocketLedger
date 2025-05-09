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
    @Environment(\.modelContext) private var modelContext
    
    @EnvironmentObject private var messageService: MessageService
    
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
        do {
            try modelContext.save()
            messageService.create(
                message: String(localized: "Transaction saved successfully", table: "Message"),
                type: .success
            )
            dismiss()
        } catch {
            messageService.create(
                message: String(localized: "Error saving data: \(error.localizedDescription)", table: "Message"),
                type: .error
            )
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(String(localized: "Transaction Type", table: "AddEditTransaction"), selection: $transactionType) {
                        Text(TransactionType.expense.localizedString).tag(TransactionType.expense)
                        Text(TransactionType.income.localizedString).tag(TransactionType.income)
                    }
                    .pickerStyle(.segmented)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .listSectionSpacing(5)
                
                Section {
                    CategoryPickerView(selectedCategory: $transactionCategory, transactionType: transactionType)
                } footer: {
                    if showCategoryEmptyWarning {
                        Text(String(localized: "Please select a category.", table: "AddEditTransaction"))
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
                    TextField(String(localized: "Amount", table: "AddEditTransaction"), value: $amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .kerning(2.0)
                        .font(.title)
                        .fontWeight(.semibold)
                        .fontDesign(.monospaced)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($amountInputFocused)
                        .keyboardType(.decimalPad)
                } header: {
                    Text(String(localized: "Amount", table: "AddEditTransaction"))
                } footer: {
                    if showAmountEmptyWarning {
                        Text(String(localized: "Please enter a valid amount.", table: "AddEditTransaction"))
                            .foregroundStyle(.red)
                    }
                }
                .onChange(of: amount) {
                    showAmountEmptyWarning = false
                }
                
                DatePicker(String(localized: "Date", table: "AddEditTransaction"), selection: $date, displayedComponents: .date)
                    .datePickerStyle(.compact)
                
                if transactionType == .expense {
                    Section {
                        Picker(String(localized: "Payment Type", table: "AddEditTransaction"), selection: $paymentType) {
                            Label(PaymentType.cash.localizedString, systemImage: "banknote").tag(PaymentType.cash)
                            if !debitCards.isEmpty {
                                Label(PaymentType.debit.localizedString, systemImage: "creditcard.and.123").tag(PaymentType.debit)
                            }
                            if !creditCards.isEmpty {
                                Label(PaymentType.credit.localizedString, systemImage: "creditcard").tag(PaymentType.credit)
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
                            Picker(paymentType?.localizedString ?? "", selection: $card) {
                                Text(String(localized: "Select a Card", table: "AddEditTransaction"))
                                    .tag(nil as Card?)
                                if paymentType == .debit {
                                    ForEach(debitCards) { card in
                                        Text("\(card.name) ••••\(card.lastFourDigits)").tag(card as Card?)
                                    }
                                } else if paymentType == .credit {
                                    ForEach(creditCards) { card in
                                        Text("\(card.name) ••••\(card.lastFourDigits)").tag(card as Card?)
                                    }
                                }
                            }
                            .onChange(of: card) {
                                showCardEmptyWarning = false
                            }
                        }
                    } footer: {
                        if showCardEmptyWarning && paymentType != .cash {
                            Text(String(localized: "Please select a card.", table: "AddEditTransaction"))
                                .foregroundStyle(.red)
                        }
                    }
                }
                
                Section(String(localized: "Notes", table: "AddEditTransaction")) {
                    TextEditor(text: $note)
                        .focused($notesInputFocused)
                }
            }
            .navigationTitle(String(localized: "Edit Transaction", table: "AddEditTransaction"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel", table: "Common")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done", table: "Common")) { save() }
                }
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button {
                            amountInputFocused = false
                            notesInputFocused = false
                        } label: {
                            Text(String(localized: "Done", table: "Common")).bold()
                        }
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
    EditTransactionView(transaction: transaction)
}
