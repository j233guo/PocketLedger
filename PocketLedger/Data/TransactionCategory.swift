//
//  TransactionCategory.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import Foundation
import SwiftData

@Model
class TransactionCategory {
    var name: String
    var icon: String // SF Symbol name
    var isCustom: Bool
    var transactionTypeRawValue: String  // Store as String
        
    var transactionType: TransactionType {
        get { TransactionType(rawValue: transactionTypeRawValue) ?? .expense }
        set { transactionTypeRawValue = newValue.rawValue }
    }
    
    @Relationship(deleteRule: .nullify) var transactions: [Transaction]?
    
    init(name: String, icon: String, isCustom: Bool, transactionType: TransactionType) {
        self.name = name
        self.icon = icon
        self.isCustom = isCustom
        self.transactionTypeRawValue = transactionType.rawValue
    }
}

struct DefaultTransactionCategoryFactory {
    static let defaultCategories: [(name: String, icon: String, type: TransactionType)] = [
        ("Payroll", "dollarsign.circle", .income),
        ("Investments", "chart.line.uptrend.xyaxis", .income),
        ("Gifts", "gift.fill", .income),
        ("Dining", "fork.knife", .expense),
        ("Groceries", "cart.fill", .expense),
        ("Gas", "fuelpump.fill", .expense),
        ("Transportation", "car.fill", .expense),
        ("Entertainment", "film.stack", .expense),
        ("Utilities", "bolt.fill", .expense),
        ("Healthcare", "heart.text.square", .expense),
        ("Shopping", "bag.fill", .expense),
        ("Travel", "airplane", .expense),
        ("Education", "book.fill", .expense),
        ("Miscellaneous", "cart.badge.questionmark", .expense)
    ]
    
    static func createDefaultCategories(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<TransactionCategory>()
        let existingCount = (try? modelContext.fetchCount(descriptor)) ?? 0
        guard existingCount == 0 else { return }
        defaultCategories.compactMap { $0 }.forEach { name, icon, category in
            let newCategory = TransactionCategory(
                name: name,
                icon: icon,
                isCustom: false,
                transactionType: category
            )
            modelContext.insert(newCategory)
        }
        try? modelContext.save()
    }
}
