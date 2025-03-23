//
//  ManageCategoryView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-20.
//

import SwiftData
import SwiftUI

private struct AddCategoryView: View {
    @Binding var expanded: Bool
    let transactionType: TransactionType
    @Binding var icon: String
    @Binding var name: String
    @FocusState.Binding var nameFieldFocused: Bool
    
    let addAction: () -> Void
    
    var body: some View {
        Section {
            if expanded {
                HStack {
                    Text("Category Name")
                    TextField("Name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.center)
                        .focused($nameFieldFocused)
                }
                CategoryIconPickerView(type: transactionType, selectedIcon: $icon)
            }
            HStack {
                if expanded {
                    Button {
                        withAnimation {
                            expanded = false
                        }
                    } label: {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderless)
                    
                    Spacer()
                }
                Button {
                    withAnimation {
                        if expanded {
                            addAction()
                        }
                        expanded.toggle()
                    }
                } label: {
                    if expanded {
                        Text("Add")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Add a Custom Category")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderless)
            }
        }
    }
}

private struct CategoryListRowView: View {
    var category: TransactionCategory
    
    var body: some View {
        HStack {
            CategoryIconView(category: category)
            Text(category.name)
                .font(.headline)
                .padding(.horizontal)
        }
    }
}

struct ManageCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    
    @EnvironmentObject private var messageService: MessageService
    
    @State private var transactionType: TransactionType = .expense
    @State private var addCategoryViewExpanded = false
    @State private var newCategoryIconName = "ellipsis"
    @State private var newCategoryName = "New Category"
    
    @FocusState private var newCategoryNameFieldFocused: Bool
    
    @Query private var defaultIncomeCategories: [TransactionCategory]
    @Query private var defaultExpenseCategories: [TransactionCategory]
    @Query private var customIncomeCategories: [TransactionCategory]
    @Query private var customExpenseCategories: [TransactionCategory]
    
    init() {
        let defaultIncomePredicate = #Predicate<TransactionCategory> {
            $0.transactionTypeRawValue == "Income" && $0.isCustom == false
        }
        let defaultExpensePredicate = #Predicate<TransactionCategory> {
            $0.transactionTypeRawValue == "Expense" && $0.isCustom == false
        }
        let customIncomePredicate = #Predicate<TransactionCategory> {
            $0.transactionTypeRawValue == "Income" && $0.isCustom == true
        }
        let customExpensePredicate = #Predicate<TransactionCategory> {
            $0.transactionTypeRawValue == "Expense" && $0.isCustom == true
        }
        _defaultIncomeCategories = Query(filter: defaultIncomePredicate, sort: \.index)
        _defaultExpenseCategories = Query(filter: defaultExpensePredicate, sort: \.index)
        _customIncomeCategories = Query(filter: customIncomePredicate, sort: \.index)
        _customExpenseCategories = Query(filter: customExpensePredicate, sort: \.index)
    }
    
    private func addCategory() {
        do {
            // Get the largest index among all categories
            let fetchDescriptor = FetchDescriptor<TransactionCategory>(
                sortBy: [SortDescriptor(\.index, order: .reverse)]
            )
            let allCategories = try modelContext.fetch(fetchDescriptor)
            let newCategoryIndex = allCategories.first?.index ?? 0
            let newCategory = TransactionCategory(
                name: newCategoryName,
                transactionType: transactionType,
                isCustom: true,
                index: newCategoryIndex,
                icon: newCategoryIconName
            )
            modelContext.insert(newCategory)
            try modelContext.save()
        } catch {
            messageService.create(
                message: "Encountered error when adding new category: \(error.localizedDescription)",
                type: .error
            )
        }
    }
    
    private func deleteCategory(at offsets: IndexSet) {
        do {
            for index in offsets {
                if transactionType == .expense {
                    modelContext.delete(customExpenseCategories[index])
                } else {
                    modelContext.delete(customIncomeCategories[index])
                }
            }
            try modelContext.save()
        } catch {
            messageService.create(
                message: "Encountered error syncing data after deleted category: \(error.localizedDescription)",
                type: .error
            )
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Picker("type", selection: $transactionType) {
                    Text("Expense")
                        .tag(TransactionType.expense)
                    Text("Income")
                        .tag(TransactionType.income)
                }
                .pickerStyle(.segmented)
                
                Section {
                    if transactionType == .expense {
                        ForEach(defaultExpenseCategories) {
                            CategoryListRowView(category: $0)
                        }
                    } else {
                        ForEach(defaultIncomeCategories) {
                            CategoryListRowView(category: $0)
                        }
                    }
                } header: {
                    Text("Default Categories")
                } footer: {
                    Text("Default categories cannot be deleted.")
                }
                
                Section {
                    if transactionType == .expense {
                        ForEach(customExpenseCategories) {
                            CategoryListRowView(category: $0)
                        }
                        .onDelete(perform: deleteCategory)
                    } else {
                        ForEach(customExpenseCategories) {
                            CategoryListRowView(category: $0)
                        }
                        .onDelete(perform: deleteCategory)
                    }
                } header: {
                    Text("Custom Categories")
                } footer: {
                    if transactionType == .expense && customExpenseCategories.isEmpty {
                        Text("You don't have any custom expense categories yet.")
                    } else if transactionType == .income && customIncomeCategories.isEmpty {
                        Text("You don't have any custom income categories yet.")
                    }
                }
                
                AddCategoryView(
                    expanded: $addCategoryViewExpanded,
                    transactionType: transactionType,
                    icon: $newCategoryIconName,
                    name: $newCategoryName,
                    nameFieldFocused: $newCategoryNameFieldFocused
                ) { addCategory() }
            }
            .navigationTitle("Transaction Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button {
                            newCategoryNameFieldFocused = false
                        } label: {
                            Text("Done").bold()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    if let container = createPreviewModelContainer() {
        container.mainContext.insert(DefaultTransactionCategoryFactory.incomeExample)
        container.mainContext.insert(DefaultTransactionFactory.expenseExample)
        return ManageCategoryView()
            .modelContainer(container)
    } else {
        return ManageCategoryView()
    }
}
