//
//  CategoryPickerView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-03.
//

import SwiftData
import SwiftUI

struct CategoryPickerView: View {
    @Query private var categories: [TransactionCategory]
    
    @Binding var selectedCategory: TransactionCategory?
    
    var transactionType: TransactionType
    
    init(selectedCategory: Binding<TransactionCategory?>, transactionType: TransactionType) {
        self._selectedCategory = selectedCategory
        self.transactionType = transactionType
        let predicate = #Predicate<TransactionCategory> {
            $0.transactionTypeRawValue == transactionType.rawValue
        }
        self._categories = Query(filter: predicate)
    }
    
    var body: some View {
        Picker("Category", selection: $selectedCategory) {
            ForEach(categories) { category in
                HStack {
                    Image(systemName: category.icon)
                    Text(category.name)
                }.tag(category as TransactionCategory?)
            }
        }
    }
}

#Preview {
    let selectedCategory = TransactionCategory(name: "", icon: "", isCustom: false, transactionType: .expense)
    CategoryPickerView(selectedCategory: .constant(selectedCategory), transactionType: .expense)
}
