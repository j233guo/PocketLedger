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
        paymentType: PaymentType? = nil,
        category: TransactionCategory? = nil,
        card: Card? = nil
    ) {
        self.amount = amount
        self.date = date
        self.transactionType = transactionType
        self.paymentType = paymentType
        self.category = category
        self.card = card
    }
}
