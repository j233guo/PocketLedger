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

extension Double {
    /// Converts `Double` to a string with up to 2 decimal places if needed.
    /// Removes trailing zeros for cleaner display.
    /// - Returns: String with the formatted number.
    func asMinimalDecimalString() -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

func formattedRewardMultiplier(_ perkType: CardPerkType, _ value: Double) -> String {
    switch perkType {
    case .cashBack:
        return "\(value.asMinimalDecimalString())%"
    case .points:
        return "\(value.asMinimalDecimalString())x"
    }
}
