//
//  TwoDecimalString.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-12.
//

import Foundation

extension Double {
    /// Converts `Double` to a string with up to 2 decimal places if needed.
    /// Removes trailing zeros for cleaner display.
    /// - Returns: String with the formatted number.
    func twoDecimalString() -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
