//
//  CalculateReward.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-11.
//

import Foundation

/// Calculates the rewards accured on a credit card in a transaction based on category.
/// If the card is a cash back card it will return the cash back value.
/// If the card is a reward points card it will return the rounded reward point value.
/// If a card perk category is `nil` the category will be default for all transactions without a defined matching category.
/// - Parameter card: the `Card` used in a `Transaction`
/// - Parameter transaction: the `Transaction` for calculation
/// - Returns: A `Double` representing the calculated reward amount on transaction paid using card
func calculateReward(card: Card, transaction: Transaction) -> Double {
    if let perks = card.perks {
        let basicRate = perks.first(where: { $0.category == nil })?.value ?? 0.0
        let perkRate = perks.first(where: { $0.category == transaction.category })?.value ?? basicRate
        let rewardAmount = card.perkType == .points ? transaction.amount * perkRate : transaction.amount * perkRate * 0.01
        if card.perkType == .points {
            return rewardAmount.rounded()
        } else {
            return round(rewardAmount * 100) / 100.0
        }
    }
    return 0.0
}
