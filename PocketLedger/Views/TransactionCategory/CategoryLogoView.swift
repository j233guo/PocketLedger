//
//  CategoryLogoView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-06.
//

import SwiftUI

struct CategoryLogoView: View {
    let category: TransactionCategory?
    var size: CGFloat = 20

    var body: some View {
        Image(systemName: category?.icon ?? "questionmark.circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .padding(size / 5)
            .background(category?.transactionType == .income ? .green : .orange)
            .clipShape(RoundedRectangle(cornerRadius: size / 5))
            .foregroundColor(.white)
    }
}

#Preview {
    let category = TransactionCategory(
        name: "Payroll",
        transactionType: .income,
        isCustom: false,
        index: 0,
        icon: "dollarsign.circle"
    )
    CategoryLogoView(category: category)
}
