//
//  Card.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import Foundation
import SwiftData

enum CardType: String, Codable, CaseIterable {
    case debit = "Debit"
    case credit = "Credit"
}

enum CardPaymentNetwork: String, Codable, CaseIterable {
    case interac = "Interac"
    case visa = "VISA"
    case mastercard = "Mastercard"
    case amex = "American Express"
}

@Model
class Card {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var cardTypeRawValue: String
    var paymentNetwork: CardPaymentNetwork
    var lastFourDigits: String
    
    var idString: String = ""
    
    var cardType: CardType {
        get { CardType(rawValue: cardTypeRawValue) ?? .debit }
        set { cardTypeRawValue = newValue.rawValue }
    }
    
    @Relationship(deleteRule: .nullify) var transactions: [Transaction]?
    @Relationship(deleteRule: .cascade) var perks: [CardPerk]
    
    init(name: String, cardType: CardType, paymentNetwork: CardPaymentNetwork, lastFourDigits: String, perks: [CardPerk] = []) {
        self.name = name
        self.cardTypeRawValue = cardType.rawValue
        self.paymentNetwork = paymentNetwork
        self.lastFourDigits = lastFourDigits
        self.perks = perks
        self.idString = id.uuidString
    }
}
