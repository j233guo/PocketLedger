//
//  CategoryPickerView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-03.
//

import SwiftData
import SwiftUI

enum CategoryPickerViewNameId {
    case transaction
    case cardperk
}

struct CategoryPickerView: View {
    @Query private var categories: [TransactionCategory]
    
    @Binding var selectedCategory: TransactionCategory?
    
    let nameId: CategoryPickerViewNameId
    var transactionType: TransactionType
    
    init(selectedCategory: Binding<TransactionCategory?>, transactionType: TransactionType, nameId: CategoryPickerViewNameId = .transaction) {
        self.nameId = nameId
        self._selectedCategory = selectedCategory
        self.transactionType = transactionType
        let predicate = #Predicate<TransactionCategory> {
            $0.transactionTypeRawValue == transactionType.rawValue
        }
        self._categories = Query(filter: predicate, sort: \TransactionCategory.index)
    }
    
    var body: some View {
        Picker("Category", selection: $selectedCategory) {
            if nameId == .transaction {
                Text("Select a Category")
                    .tag(nil as TransactionCategory?)
            } else if nameId == .cardperk {
                Text("Everything")
                    .tag(nil as TransactionCategory?)
            }
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
    let selectedCategory = TransactionCategory(
        name: "",
        transactionType: .expense,
        isCustom: false,
        index: 0,
        icon: ""
    )
    CategoryPickerView(selectedCategory: .constant(selectedCategory), transactionType: .expense)
}
