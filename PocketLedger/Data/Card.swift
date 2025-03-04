//
//  Card.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import Foundation
import SwiftData

enum CardType: String, Codable, CaseIterable {
    case debit, credit
}

enum CardPaymentNetwork: String, Codable, CaseIterable {
    case interac = "Interac"
    case visa = "VISA"
    case mastercard = "Mastercard"
    case amex = "American Express"
}

@Model
class Card {
    var name: String
    var cardType: CardType
    var paymentNetwork: CardPaymentNetwork
    var lastFourDigits: String
    
    private var _perks: Data?
    
    var perks: [CardReward] {
        get { decodePerks() }
        set { encodePerks(newValue) }
    }
    
    @Relationship(deleteRule: .nullify) var transactions: [Transaction]?
    
    init(name: String, cardType: CardType, paymentNetwork: CardPaymentNetwork, lastFourDigits: String) {
        self.name = name
        self.cardType = cardType
        self.paymentNetwork = paymentNetwork
        self.lastFourDigits = lastFourDigits
    }
    
    private func encodePerks(_ perks: [CardReward]) {
        _perks = try? JSONEncoder().encode(perks)
    }
    
    private func decodePerks() -> [CardReward] {
        guard let data = _perks else { return [] }
        return (try? JSONDecoder().decode([CardReward].self, from: data)) ?? []
    }
}

// Perk Structure
struct CardReward: Codable {
    var perkType: String // e.g., "Cash Back", "Travel Points"
    var value: Double // e.g., 1.5 = 1.5% cash back
    var description: String
}
