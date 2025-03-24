//
//  CategoryIconLibraryView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-21.
//

import SwiftUI

struct CategoryIconLibraryView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedIcon: String
    
    let type: TransactionType
    
    private let iconLibraryDictionary: [(header: String, icons: [String])] = [
        (String(localized: "Food and Drink", table: "Category"), IconLibrary.foodAndDrink),
        (String(localized: "Entertainment", table: "Category"), IconLibrary.entertainment),
        (String(localized: "Travel and Transportation", table: "Category"), IconLibrary.travelAndTransport),
        (String(localized: "Sports", table: "Category"), IconLibrary.sports),
        (String(localized: "Hobbies", table: "Category"), IconLibrary.hobbies),
        (String(localized: "Shopping", table: "Category"), IconLibrary.shopping),
        (String(localized: "Finance", table: "Category"), IconLibrary.finance),
        (String(localized: "Tools and Utilities", table: "Category"), IconLibrary.tools),
        (String(localized: "Education and Information", table: "Category"), IconLibrary.educationAndInformation),
        (String(localized: "Healthcare", table: "Category"), IconLibrary.healthcare),
        (String(localized: "Miscellaneous", table: "Category"), IconLibrary.miscellaneous),
    ]
    
    var body: some View {
        List {
            ForEach(iconLibraryDictionary, id: \.header) { section in
                Section {
                    LazyVGrid(columns: Array(repeating: .init(), count: 4), spacing: 10) {
                        ForEach(section.icons, id: \.self) { icon in
                            ZStack {
                                let selected = selectedIcon == icon
                                if selected {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(.selection)
                                }
                                Image(systemName: icon)
                                    .font(.title)
                                    .frame(width: 30, height: 30)
                                    .padding(10)
                                    .foregroundStyle(selected ? .white : .primary)
                            }
                            .onTapGesture {
                                selectedIcon = icon
                                dismiss()
                            }
                        }
                    }
                } header: {
                    Text(section.header)
                }
            }
        }
        .navigationTitle(String(localized: "Select an Icon", table: "Category"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    CategoryIconLibraryView(selectedIcon: .constant("ellipsis"), type: .expense)
}
