//
//  CategoryIconView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-06.
//

import SwiftUI

struct CategoryIconView: View {
    let category: TransactionCategory?
    var size: CGFloat = 20
    let icon: String
    let transactionType: TransactionType?
    
    init(category: TransactionCategory? = nil, size: CGFloat = 20) {
        self.category = category
        self.icon = self.category?.icon ?? "ellipsis"
        self.transactionType = category?.transactionType
        self.size = size
    }
    
    init(icon: String, type: TransactionType, size: CGFloat = 20) {
        self.category = nil
        self.icon = icon
        self.transactionType = type
        self.size = size
    }

    var body: some View {
        Image(systemName: icon)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .padding(size / 5)
            .background(transactionType == .income ? Color("IncomeColor") : Color("ExpenseColor"))
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
    CategoryIconView(category: category)
}
