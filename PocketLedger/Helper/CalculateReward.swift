//
//  CalculateReward.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-11.
//

import Foundation

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
