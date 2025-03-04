//
//  CardPerk.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-04.
//

import Foundation
import SwiftData

enum CardPerkType: String, Codable, CaseIterable {
    case cashBack
    case points
}

@Model
class CardPerk {
    var perkType: CardPerkType
    var value: Double
    var category: TransactionCategory?
    
    @Relationship(deleteRule: .noAction) var card: Card
    
    init(card: Card, perkType: CardPerkType, value: Double, category: TransactionCategory? = nil) {
        self.card = card
        self.perkType = perkType
        self.value = value
        self.category = category
    }
}
