//
//  CategoryIconPickerView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-21.
//

import SwiftUI

struct CategoryIconPickerView: View {
    let type: TransactionType
    @Binding var selectedIcon: String
    
    private let icons: [String] = []
    
    var body: some View {
        NavigationLink {
            CategoryIconLibraryView(selectedIcon: $selectedIcon, type: type)
        } label: {
            HStack {
                Text(String(localized: "Icon", table: "Category"))
                Spacer()
                CategoryIconView(icon: selectedIcon, type: type, size: 25)
            }
        }
    }
}

#Preview {
    NavigationStack {
        List {
            CategoryIconPickerView(type: .expense, selectedIcon: .constant("ellipsis"))
        }
    }
}
