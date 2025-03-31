//
//  HexColor.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-31.
//

import SwiftUI

extension Color {
    /// Initializing a Color using hex value
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}
