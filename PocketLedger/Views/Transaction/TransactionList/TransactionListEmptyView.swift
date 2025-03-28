//
//  TransactionListEmptyView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-19.
//

import SwiftUI

struct TransactionListEmptyView: View {
    var message: String
    
    var body: some View {
        VStack {
            Text(String(localized: "Empty Transaction List", table: "TransactionList"))
                .font(.title)
            Text(message)
                .font(.footnote)
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    TransactionListEmptyView(message: "You don't have any transactions")
}
