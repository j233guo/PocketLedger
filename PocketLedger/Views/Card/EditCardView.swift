//
//  EditCardView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-07.
//

import SwiftData
import SwiftUI

private struct AddPerkView: View {
    @Binding var expanded: Bool
    @Binding var value: Double
    @Binding var category: TransactionCategory?
    @Binding var showDuplicateCategoryWarning: Bool
    @FocusState.Binding var valueFieldFocused: Bool
    
    let perkType: CardPerkType
    let addAction: () -> Bool
    
    private let valueFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    var addPerkButton: some View {
        HStack {
            if expanded {
                Button {
                    withAnimation {
                        expanded = false
                        showDuplicateCategoryWarning = false
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
                        if addAction() {
                            expanded = false
                            showDuplicateCategoryWarning = false
                        } else {
                            showDuplicateCategoryWarning = true
                        }
                    }
                } label: {
                    Text(expanded ? String(localized: "Add", table: "Common") :
                            String(localized: "Add a New Perk", table: "AddEditCard"))
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
                    Text(expanded ? String(localized: "Add", table: "Common") :
                            String(localized: "Add a New Perk", table: "AddEditCard"))
                        .fontWeight(.semibold)
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
    
    var addForm: some View {
        Section {
            if expanded {
                HStack {
                    let suffix = perkType == .cashback ? "%" : "x"
                    Text(String(localized: "\(perkType.localizedString) Multiplier", table: "AddEditCard"))
                    TextField(String(localized: "\(perkType.localizedString) Multiplier", table: "AddEditCard"), value: $value, formatter: valueFormatter)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(.plain)
                        .keyboardType(.decimalPad)
                        .focused($valueFieldFocused)
                    Text(suffix)
                        .foregroundStyle(.secondary)
                }
                CategoryPickerView(selectedCategory: $category, transactionType: .expense, nameId: .cardperk)
            }
        } footer: {
            if showDuplicateCategoryWarning {
                Text(String(localized: "There is already a perk with this category.", table: "AddEditCard"))
                    .foregroundStyle(.red)
            }
        }
    }
    
    var body: some View {
        addForm
        Section {
            addPerkButton
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
        }
        .listSectionSpacing(10)
    }
}

struct EditCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @EnvironmentObject private var messageService: MessageService
    
    @State private var cardName = ""
    @State private var cardType: CardType = .debit
    @State private var paymentNetwork: CardPaymentNetwork = .interac
    @State private var lastFourDigits: String = ""
    @State private var cardPerkType: CardPerkType = .points
    
    @State private var showNameEmptyWarning = false
    @State private var showLastFourDigitsEmptyWarning = false
    
    @State private var showPerkResetAlert = false
    @State private var addPerkExpanded = false
    @State private var addPerkValue: Double = 1.0
    @State private var addPerkCategory: TransactionCategory? = nil
    @State private var showPerkDuplicateCategoryWarning: Bool = false
    
    @FocusState private var nameFieldIsFocused: Bool
    @FocusState private var lastFourDigitsFieldIsFocused: Bool
    @FocusState private var addPerkValueFieldFocused: Bool
    
    @Query(sort: \CardPerk.value) private var perksOnCard: [CardPerk]
    
    var card: Card
    
    init(card: Card) {
        self.card = card
        let idString = card.idString
        let predicate = #Predicate<CardPerk> {
            $0.card?.idString == idString
        }
        self._perksOnCard = Query(filter: predicate)
    }
    
    private func addCardPerk() -> Bool {
        if card.perkType == nil {
            card.perkType = cardPerkType
        }
        if card.perks?.firstIndex(where: { $0.category?.id == addPerkCategory?.id }) != nil {
            return false
        }
        let newPerk = CardPerk(
            card: card,
            perkType: card.perkType!,
            value: addPerkValue,
            category: addPerkCategory
        )
        modelContext.insert(newPerk)
        return true
    }
    
    private func deletePerk(at offsets: IndexSet) {
        for index in offsets {
            let perk = perksOnCard[index]
            modelContext.delete(perk)
        }
    }
    
    private func removeAllPerksOnCard() {
        for perk in perksOnCard {
            modelContext.delete(perk)
        }
    }
    
    private func save() {
        if cardName.isEmpty {
            showNameEmptyWarning = true
        }
        if lastFourDigits.isEmpty || lastFourDigits.count != 4 {
            showLastFourDigitsEmptyWarning = true
        }
        guard !showNameEmptyWarning && !showLastFourDigitsEmptyWarning else { return }
        card.name = cardName
        card.cardType = cardType
        card.paymentNetwork = paymentNetwork
        card.lastFourDigits = lastFourDigits
        if card.cardType == .credit {
            card.perkType = cardPerkType
        } else {
            card.perkType = nil
            removeAllPerksOnCard()
        }
        do {
            try modelContext.save()
            messageService.create(
                message: String(localized: "Card saved successfully", table: "Message"),
                type: .success
            )
            dismiss()
        } catch {
            messageService.create(
                message: String(localized: "Error saving data: \(error.localizedDescription)", table: "Message"),
                type: .error
            )
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(String(localized: "Card Name", table: "AddEditCard"), text: $cardName)
                        .onChange(of: cardName) {
                            showNameEmptyWarning = false
                        }
                } header: {
                    Text(String(localized: "Name for the card", table: "AddEditCard"))
                } footer: {
                    if showNameEmptyWarning {
                        Text(String(localized: "Please enter a name for the card.", table: "AddEditCard"))
                            .foregroundStyle(.red)
                    }
                }
                
                Section {
                    Picker(String(localized: "Card Type", table: "AddEditCard"), selection: $cardType) {
                        Text(CardType.debit.localizedString).tag(CardType.debit)
                        Text(CardType.credit.localizedString).tag(CardType.credit)
                    }
                    .onChange(of: cardType) {
                        if cardType == card.cardType {
                            paymentNetwork = card.paymentNetwork
                        } else {
                            if cardType == .debit {
                                paymentNetwork = .interac
                            } else if cardType == .credit {
                                paymentNetwork = .visa
                            }
                        }
                    }
                    
                    if cardType == .credit {
                        Picker(String(localized: "Payment Network", table: "AddEditCard"), selection: $paymentNetwork) {
                            Text(CardPaymentNetwork.visa.localizedString).tag(CardPaymentNetwork.visa)
                            Text(CardPaymentNetwork.mastercard.localizedString).tag(CardPaymentNetwork.mastercard)
                            Text(CardPaymentNetwork.amex.localizedString).tag(CardPaymentNetwork.amex)
                        }
                    }
                }
                
                Section {
                    TextField("1234", text: Binding(
                        get: { lastFourDigits },
                        set: { newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered.count <= 4 {
                                lastFourDigits = String(filtered.prefix(4))
                            }
                        }
                    ))
                    .kerning(2.0)
                    .font(.title)
                    .fontWeight(.semibold)
                    .fontDesign(.monospaced)
                    .multilineTextAlignment(.center)
                    .focused($lastFourDigitsFieldIsFocused)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: lastFourDigits) {
                        showLastFourDigitsEmptyWarning = false
                    }
                } header: {
                    Text(String(localized: "Last four digits of the card", table: "AddEditCard"))
                } footer: {
                    if showLastFourDigitsEmptyWarning {
                        Text(String(localized: "Please enter the last four digits of the card.", table: "AddEditCard"))
                            .foregroundStyle(.red)
                    } else {
                        Text(String(localized: "For identifying purpose only.", table: "AddEditCard"))
                    }
                }
                
                if cardType == .credit {
                    Section {
                        Picker(String(localized: "Card Perk Type", table: "AddEditCard"), selection: $cardPerkType) {
                            Text(CardPerkType.points.localizedString).tag(CardPerkType.points)
                            Text(CardPerkType.cashback.localizedString).tag(CardPerkType.cashback)
                        }
                        .onChange(of: cardPerkType) {
                            if cardPerkType != card.perkType && !perksOnCard.isEmpty {
                                showPerkResetAlert = true
                            }
                        }
                    }
                    .alert(String(localized: "Card Perk", table: "AddEditCard"), isPresented: $showPerkResetAlert) {
                        Button(String(localized: "Don't Proceed", table: "AddEditCard"), role: .cancel) {
                            if let perkType = card.perkType {
                                cardPerkType = perkType
                            }
                            showPerkResetAlert = false
                        }
                        Button(String(localized: "Proceed", table: "AddEditCard"), role: .destructive) {
                            removeAllPerksOnCard()
                            showPerkResetAlert = false
                        }
                    } message: {
                        Text(String(localized: "Changing perk type will clear all perks on this card.", table: "AddEditCard"))
                    }
                    
                    Section {
                        ForEach(perksOnCard) { perk in
                            CardPerkListRowView(perk: perk)
                        }
                        .onDelete(perform: deletePerk)
                        .id("perksList")
                    } header: {
                        Text(String(localized: "Perks on This card", table: "AddEditCard"))
                    } footer: {
                        if perksOnCard.isEmpty {
                            Text(String(localized: "This card doesn't have any perks registered.", table: "AddEditCard"))
                        }
                    }
                    
                    AddPerkView(
                        expanded: $addPerkExpanded,
                        value: $addPerkValue,
                        category: $addPerkCategory,
                        showDuplicateCategoryWarning: $showPerkDuplicateCategoryWarning,
                        valueFieldFocused: $addPerkValueFieldFocused,
                        perkType: cardPerkType
                    ) { addCardPerk() }
                }
            }
            .navigationTitle(String(localized: "Edit Card", table:"AddEditCard"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel", table: "Common")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done", table: "Common")) { save() }
                }
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button {
                            if nameFieldIsFocused {
                                nameFieldIsFocused = false
                            }
                            if lastFourDigitsFieldIsFocused {
                                lastFourDigitsFieldIsFocused = false
                            }
                            if addPerkValueFieldFocused {
                                addPerkValueFieldFocused = false
                            }
                        } label: {
                            Text(String(localized: "Done", table: "Common")).bold()
                        }
                    }
                }
            }
            .onAppear {
                cardName = card.name
                cardType = card.cardType
                paymentNetwork = card.paymentNetwork
                lastFourDigits = card.lastFourDigits
                if let perkType = card.perkType {
                    cardPerkType = perkType
                }
            }
        }
    }
}

#Preview {
    let card = Card(
        name: "My Credit Card",
        cardType: .credit,
        paymentNetwork: .amex,
        lastFourDigits: "1000",
        perkType: .points
    )
    if let container = createPreviewModelContainer() {
        EditCardView(card: card)
            .modelContainer(container)
    } else {
        EditCardView(card: card)
    }
}
