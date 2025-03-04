//
//  CardLogoView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-03.
//

import SwiftUI

struct CardLogoView: View {
    let network: CardPaymentNetwork
    var size = 35.0
    
    private let logoNameDictionary: [CardPaymentNetwork: String] = [
        .amex: "amex_logo",
        .mastercard: "mastercard_logo",
        .visa: "visa_logo",
        .interac: "interac_logo",
    ]
    
    var body: some View {
        Image("\(logoNameDictionary[network] ?? "")")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .padding(1)
    }
}

#Preview {
    HStack {
        CardLogoView(network: .amex, size: 75)
        CardLogoView(network: .interac, size: 75)
        CardLogoView(network: .visa, size: 75)
        CardLogoView(network: .mastercard, size: 75)
    }
}
