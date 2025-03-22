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
        ("Food and Drink", IconLibrary.foodAndDrink),
        ("Entertainment", IconLibrary.entertainment),
        ("Travel and Transportation", IconLibrary.travelAndTransport),
        ("Sports", IconLibrary.sports),
        ("Hobbies", IconLibrary.hobbies),
        ("Shopping", IconLibrary.shopping),
        ("Finance", IconLibrary.finance),
        ("Tools and Utilities", IconLibrary.tools),
        ("Education and Information", IconLibrary.educationAndInformation),
        ("Healthcare", IconLibrary.healthcare),
        ("Miscellaneous", IconLibrary.miscellaneous),
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
    }
}

#Preview {
    CategoryIconLibraryView(selectedIcon: .constant("ellipsis"), type: .expense)
}
