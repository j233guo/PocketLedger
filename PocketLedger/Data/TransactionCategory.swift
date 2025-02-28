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
    var transactionType: TransactionType
    
    @Relationship(deleteRule: .nullify) var transactions: [Transaction]?
    
    init(name: String, icon: String, isCustom: Bool, transactionType: TransactionType) {
        self.name = name
        self.icon = icon
        self.isCustom = isCustom
        self.transactionType = transactionType
    }
}

struct DefaultTransactionCategoryFactory {
    static let incomeCategories: [(name: String, icon: String)] = [
        ("Payroll", "dollarsign.circle"),
        ("Investments", "chart.line.uptrend.xyaxis"),
        ("Gifts", "gift.fill"),
    ]
    
    static let expenseCategories: [(name: String, icon: String)] = [
        ("Dining", "fork.knife"),
        ("Groceries", "cart.fill"),
        ("Gas", "fuelpump.fill"),
        ("Transportation", "car.fill"),
        ("Entertainment", "film.stack"),
        ("Utilities", "bolt.fill"),
        ("Healthcare", "heart.text.square"),
        ("Shopping", "bag.fill"),
        ("Travel", "airplane"),
        ("Education", "book.fill"),
        ("Miscellaneous", "cart.badge.questionmark")
    ]
    
    static func createDefaultCategories(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<TransactionCategory>()
        let existingCount = (try? modelContext.fetchCount(descriptor)) ?? 0
        guard existingCount == 0 else { return }
        
        // Create income categories
        for category in incomeCategories {
            let newCategory = TransactionCategory(
                name: category.name,
                icon: category.icon,
                isCustom: false,
                transactionType: .income
            )
            modelContext.insert(newCategory)
        }
        
        // Create expense categories
        for category in expenseCategories {
            let newCategory = TransactionCategory(
                name: category.name,
                icon: category.icon,
                isCustom: false,
                transactionType: .expense
            )
            modelContext.insert(newCategory)
        }
        
        try? modelContext.save()
    }
}
