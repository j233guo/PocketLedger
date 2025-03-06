//
//  Transaction.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import Foundation
import SwiftData

enum TransactionType: String, Codable, CaseIterable {
    case expense = "Expense"
    case income = "Income"
}

enum PaymentType: String, Codable, CaseIterable {
    case cash = "Cash"
    case debit = "Debit"
    case credit = "Credit Card"
}

@Model
class Transaction {
    var id: UUID
    var transactionType: TransactionType
    var amount: Double
    var date: Date
    var note: String?
    var paymentType: PaymentType?
    
    @Relationship var category: TransactionCategory?
    @Relationship var card: Card?
    
    init(
        transactionType: TransactionType,
        amount: Double,
        date: Date,
        category: TransactionCategory? = nil,
        paymentType: PaymentType? = nil,
        card: Card? = nil,
        note: String? = nil
    ) {
        self.id = UUID()
        self.transactionType = transactionType
        self.amount = amount
        self.date = date
        self.category = category
        self.paymentType = paymentType
        self.card = card
        self.note = note
    }
}
