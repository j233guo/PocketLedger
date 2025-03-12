//
//  CurrencyFormatter.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import Foundation

/// Formats a given number as a currency string using the current locale settings.
/// If the number cannot be formatted, it returns a string representation of the number itself.
/// - Parameter number: The `Double` value to be formatted as currency.
/// - Returns: A `String` representing the formatted currency value or the raw string representation of the number.
func formatCurrency(double value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale.current
    if let formattedString = formatter.string(from: NSNumber(value: value)) {
        return formattedString
    } else {
        return "\(value)"
    }
}

func formatCurrency(string value: String) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale.current
    if let number = Double(value), let formattedString = formatter.string(from: NSNumber(value: number)) {
        return formattedString
    } else {
        return value
    }
}
