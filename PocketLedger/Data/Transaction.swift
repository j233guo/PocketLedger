//
//  Transaction.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import Foundation
import SwiftData

enum TransactionType: String, Codable, CaseIterable {
    case expense, income
}

enum PaymentType: String, Codable, CaseIterable {
    case cash, debit, credit
}

@Model
class Transaction {
    var amount: Double
    var date: Date
    var note: String?
    var transactionType: TransactionType
    var paymentType: PaymentType?
    
    @Relationship var category: TransactionCategory?
    @Relationship var card: Card?
    
    init(
        amount: Double,
        date: Date,
        transactionType: TransactionType,
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
