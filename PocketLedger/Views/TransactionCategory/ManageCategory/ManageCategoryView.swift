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
    
    var addCategoryButton: some View {
        HStack {
            if expanded {
                Button {
                    withAnimation {
                        expanded = false
                    }
                } label: {
                    Text(String(localized: "Cancel", table: "Common"))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .foregroundStyle(.primary)
                .transition(.asymmetric(
                    insertion: .move(edge: .leading),
                    removal: .move(edge: .trailing)
                ))
                .animation(.default, value: expanded)
                
                Button {
                    withAnimation {
                        addAction()
                        expanded = false
                    }
                } label: {
                    Text(String(localized: "Add", table: "Common"))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
                .animation(.default, value: expanded)
            } else {
                Button {
                    withAnimation {
                        expanded = true
                    }
                } label: {
                    Text(String(localized: "Add a Custom Category", table: "Category"))
                        .font(.headline)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ))
                .animation(.default, value: expanded)
            }
        }
    }
    
    var body: some View {
        if expanded {
            Section {
                HStack {
                    Text(String(localized: "Category Name", table: "Category"))
                    TextField(String(localized: "Category Name", table: "Category"), text: $name)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.center)
                        .focused($nameFieldFocused)
                }
                CategoryIconPickerView(type: transactionType, selectedIcon: $icon)
            }
        }
        Section {
            addCategoryButton
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
        }
        .listSectionSpacing(10)
    }
}

private struct CategoryListRowView: View {
    var category: TransactionCategory
    
    var body: some View {
        HStack {
            CategoryIconView(category: category)
            Text(category.displayName)
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
    @State private var newCategoryName: String
    
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
        _newCategoryName = State(initialValue: String(localized: "Custom Category", table: "Category"))
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
                message: String(localized: "Error saving data: \(error.localizedDescription)", table: "Message"),
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
                message: String(localized: "Error saving data: \(error.localizedDescription)", table: "Message"),
                type: .error
            )
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Picker(String(localized: "Transaction Type", table: "Category"), selection: $transactionType) {
                    Text(TransactionType.expense.localizedString).tag(TransactionType.expense)
                    Text(TransactionType.income.localizedString).tag(TransactionType.income)
                }
                .pickerStyle(.segmented)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                
                Section {
                    if transactionType == .expense {
                        ForEach(customExpenseCategories) {
                            CategoryListRowView(category: $0)
                        }
                        .onDelete(perform: deleteCategory)
                    } else {
                        ForEach(customIncomeCategories) {
                            CategoryListRowView(category: $0)
                        }
                        .onDelete(perform: deleteCategory)
                    }
                } header: {
                    Text(String(localized: "Custom Categories", table: "Category"))
                } footer: {
                    if transactionType == .expense && customExpenseCategories.isEmpty {
                        Text(String(localized: "You don't have any custom expense categories yet.", table: "Category"))
                    } else if transactionType == .income && customIncomeCategories.isEmpty {
                        Text(String(localized: "You don't have any custom income categories yet.", table: "Category"))
                    }
                }
                
                AddCategoryView(
                    expanded: $addCategoryViewExpanded,
                    transactionType: transactionType,
                    icon: $newCategoryIconName,
                    name: $newCategoryName,
                    nameFieldFocused: $newCategoryNameFieldFocused
                ) { addCategory() }
                
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
                    Text(String(localized: "Default Categories", table: "Category"))
                } footer: {
                    Text(String(localized: "Default categories cannot be deleted.", table: "Category"))
                }
            }
            .navigationTitle(String(localized: "Transaction Categories", table: "Category"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button {
                            newCategoryNameFieldFocused = false
                        } label: {
                            Text(String(localized: "Done", table: "Common")).bold()
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
