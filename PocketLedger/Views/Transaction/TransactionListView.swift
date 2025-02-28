//
//  TransactionsView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import SwiftUI

struct TransactionListView: View {
    @State private var showAddTransactionView: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                
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
    TransactionListView()
}
