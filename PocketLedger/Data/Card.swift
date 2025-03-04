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
    
    @Relationship(deleteRule: .nullify) var transactions: [Transaction]?
    @Relationship(deleteRule: .cascade) var perks: [CardPerk]
    
    init(name: String, cardType: CardType, paymentNetwork: CardPaymentNetwork, lastFourDigits: String, perks: [CardPerk] = []) {
        self.name = name
        self.cardType = cardType
        self.paymentNetwork = paymentNetwork
        self.lastFourDigits = lastFourDigits
        self.perks = perks
    }
}
