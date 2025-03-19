//
//  CurrencyFormatter.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import Foundation

/// Formats a given number as a currency string using the current locale settings.
/// If the number cannot be formatted, return a string representation of the number itself.
/// - Parameter double: the `Double` value to be formatted as currency.
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

/// Formats a given number string as a currency string using the current locale settings.
/// If the number in the string cannot be parsed or formatted, return a string representation of the string itself.
/// - Parameter string: the `String` value to be formatted as currency
/// - Returns: A `String` representing the formatted currency value or the original string.
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
