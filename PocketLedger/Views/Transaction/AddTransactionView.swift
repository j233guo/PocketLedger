//
//  AddTransactionView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-02-28.
//

import SwiftData
import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    
    @Query private var transactionCategories: [TransactionCategory]
    
    func save() {
        
    }
    
    var body: some View {
        NavigationStack {
            Form {
                ForEach(transactionCategories) { category in
                    Text(category.name)
                }
            }
            .navigationTitle("Add a New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        save()
                    } label: {
                        Text("Save")
                            .bold()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}

#Preview {
    AddTransactionView()
}
