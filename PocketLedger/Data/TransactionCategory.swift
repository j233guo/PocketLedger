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
