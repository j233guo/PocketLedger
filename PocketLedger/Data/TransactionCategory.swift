//
//  TransactionCategory.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import Foundation
import SwiftData

@Model
class TransactionCategory: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var isCustom: Bool
    var index: Int
    var icon: String // SF Symbol name
    
    var transactionTypeRawValue: String  // Store as String
    var transactionType: TransactionType {
        get { TransactionType(rawValue: transactionTypeRawValue) ?? .expense }
        set { transactionTypeRawValue = newValue.rawValue }
    }
    
    @Relationship(deleteRule: .nullify, inverse: \Transaction.category) var transactions: [Transaction]?
    @Relationship(deleteRule: .cascade, inverse: \CardPerk.category) var cardPerks: [CardPerk]?
    
    init(name: String, transactionType: TransactionType, isCustom: Bool, index: Int, icon: String) {
        self.name = name
        self.transactionTypeRawValue = transactionType.rawValue
        self.isCustom = isCustom
        self.index = index
        self.icon = icon
    }
}

struct DefaultTransactionCategoryFactory {
    static private let defaultCategories: [(name: String, type: TransactionType, index: Int, icon: String)] = [
        ("Payroll", .income, 0, "dollarsign.circle"),
        ("Investments", .income, 1, "chart.line.uptrend.xyaxis"),
        ("Gifts", .income, 2, "gift"),
        ("Dining", .expense, 3, "fork.knife"),
        ("Gas", .expense, 4, "fuelpump"),
        ("Groceries", .expense, 5, "cart"),
        ("Transportation", .expense, 6, "car"),
        ("Shopping", .expense, 7, "bag"),
        ("Entertainment", .expense, 8, "film.stack"),
        ("Utilities", .expense, 9, "bolt"),
        ("Healthcare", .expense, 10, "heart.text.square"),
        ("Travel", .expense, 11, "airplane"),
        ("Education", .expense, 12, "book"),
        ("Miscellaneous", .expense, 13, "cart.badge.questionmark")
    ]
    
    static func createDefaultCategories(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<TransactionCategory>()
        let existingCount = (try? modelContext.fetchCount(descriptor)) ?? 0
        guard existingCount == 0 else { return }
        defaultCategories.compactMap { $0 }.forEach { name, category, index, icon in
            let newCategory = TransactionCategory(
                name: name,
                transactionType: category,
                isCustom: false,
                index: index,
                icon: icon
            )
            modelContext.insert(newCategory)
        }
        try? modelContext.save()
    }
    
    static var expenseExample: TransactionCategory {
        return TransactionCategory(
            name: "Dining",
            transactionType: .expense,
            isCustom: false,
            index: 1,
            icon: "fork.knife"
        )
    }
    
    static var incomeExample: TransactionCategory {
        return TransactionCategory(
            name: "Payroll",
            transactionType: .income,
            isCustom: false,
            index: 0,
            icon: "dollarsign.circle"
        )
    }
}
