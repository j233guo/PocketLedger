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
    
    var localizedString: String {
        String(localized: String.LocalizationValue(rawValue), table: "EnumRawValue")
    }
}

enum CardPaymentNetwork: String, Codable, CaseIterable {
    case interac = "Interac"
    case visa = "VISA"
    case mastercard = "Mastercard"
    case amex = "American Express"
    
    var localizedString: String {
        String(localized: String.LocalizationValue(rawValue), table: "EnumRawValue")
    }
}

@Model
class Card {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var cardTypeRawValue: String
    var paymentNetwork: CardPaymentNetwork
    var lastFourDigits: String
    var perkType: CardPerkType?
    
    var idString: String = ""
    
    var cardType: CardType {
        get { CardType(rawValue: cardTypeRawValue) ?? .debit }
        set { cardTypeRawValue = newValue.rawValue }
    }
    
    @Relationship(deleteRule: .nullify, inverse: \Transaction.card) var transactions: [Transaction]?
    @Relationship(deleteRule: .cascade, inverse: \CardPerk.card) var perks: [CardPerk]?
    
    init(name: String, cardType: CardType, paymentNetwork: CardPaymentNetwork, lastFourDigits: String, perkType: CardPerkType? = nil) {
        self.name = name
        self.cardTypeRawValue = cardType.rawValue
        self.paymentNetwork = paymentNetwork
        self.lastFourDigits = lastFourDigits
        self.perkType = perkType
        self.idString = id.uuidString
    }
}
