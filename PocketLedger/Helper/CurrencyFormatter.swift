//
//  CurrencyFormatter.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import Foundation

/// Formats a given number as a currency string using the current locale settings.
///
/// The function uses `NumberFormatter` to convert a `Double` value to a localized currency string.
/// It respects the user's current locale, which dictates the currency symbol, the number of decimal
/// places, and other formatting details. If the number cannot be formatted (which is unlikely in normal
/// circumstances), it returns a string representation of the number itself.
///
/// - Parameter number: The `Double` value to be formatted as currency.
/// - Returns: A `String` representing the formatted currency value. If formatting fails, it returns
///   the raw string representation of the number.
func formatCurrency(_ number: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale.current
    if let formattedAmount = formatter.string(from: NSNumber(value: number)) {
        return formattedAmount
    } else {
        return "\(number)"
    }
}
