//
//  CardPerk.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-04.
//

import Foundation
import SwiftData

enum CardPerkType: String, Codable, CaseIterable {
    case cashback = "Cashback"
    case points = "Points"
    
    var localizedString: String {
        String(localized: String.LocalizationValue(rawValue), table: "EnumRawValue")
    }
}

@Model
class CardPerk {
    var perkType: CardPerkType
    var value: Double
    var category: TransactionCategory?
    
    @Relationship(deleteRule: .noAction) var card: Card?
    
    init(card: Card, perkType: CardPerkType, value: Double, category: TransactionCategory? = nil) {
        self.card = card
        self.perkType = perkType
        self.value = value
        self.category = category
    }
}

func formattedRewardMultiplier(_ perkType: CardPerkType, _ value: Double) -> String {
    switch perkType {
    case .cashback:
        return "\(value.decimalStr(2))%"
    case .points:
        return "\(value.decimalStr(2))x"
    }
}
