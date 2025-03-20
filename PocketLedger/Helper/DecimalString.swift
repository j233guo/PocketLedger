//
//  DecimalString.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-12.
//

import Foundation

extension Double {
    /// Converts `Double` to a string with up to a specific number of decimal places if needed.
    /// Removes trailing zeros for cleaner display.
    /// - Parameter digits: Number of decimal places to be formatted to
    /// - Returns: String with the formatted number.
    func decimalStr(_ digits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = digits
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
