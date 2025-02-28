//
//  TransactionsView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import SwiftData
import SwiftUI

struct TransactionListView: View {
    @State private var showAddTransactionView: Bool = false
    
    @Query private var transactions: [Transaction]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(transactions) {
                    Text("\($0.amount)")
                }
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add", systemImage: "plus.circle") {
                        showAddTransactionView = true
                    }
                }
            }
            .sheet(isPresented: $showAddTransactionView) {
                AddTransactionView()
            }
        }
    }
}

#Preview {
    if let container = createPreviewModelContainer() {
        TransactionListView()
            .modelContainer(container)
    } else {
        TransactionListView()
    }
}
