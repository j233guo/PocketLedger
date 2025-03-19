//
//  EditCardView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-07.
//

import SwiftData
import SwiftUI

struct AddPerkView: View {
    @Binding var expanded: Bool
    @Binding var value: Double
    @Binding var category: TransactionCategory?
    @FocusState.Binding var valueFieldFocused: Bool
    
    let perkType: CardPerkType
    let addAction: () -> Void
    
    private let valueFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    var body: some View {
        Section {
            if expanded {
                Group {
                    HStack {
                        let suffix = perkType == .cashback ? "%" : "x"
                        Text("\(perkType.rawValue) Multiplier")
                        TextField("Value", value: $value, formatter: valueFormatter)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(.plain)
                            .keyboardType(.decimalPad)
                            .focused($valueFieldFocused)
                        Text(suffix)
                            .foregroundStyle(.secondary)
                    }
                    CategoryPickerView(selectedCategory: $category, transactionType: .expense, nameId: .cardperk)
                }
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
                        Text("Add a New Perk")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderless)
            }
        }
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
    
    @FocusState private var nameFieldIsFocused: Bool
    @FocusState private var lastFourDigitsFieldIsFocused: Bool
    @FocusState private var addPerkValueFieldFocused: Bool
    
    @Query(sort: \CardPerk.value) private var perksOnCard: [CardPerk]
    
    var card: Card
    
    init(card: Card) {
        self.card = card
        let idString = card.idString
        let predicate = #Predicate<CardPerk> {
            $0.card.idString == idString
        }
        self._perksOnCard = Query(filter: predicate)
        
    }
    
    private func addCardPerk() {
        let newPerk = CardPerk(
            card: card,
            perkType: card.perkType!,
            value: addPerkValue,
            category: addPerkCategory
        )
        modelContext.insert(newPerk)
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
        cardType = cardType
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
                message: "Card saved successfully",
                type: .success
            )
            dismiss()
        } catch {
            messageService.create(
                message: "Encountered error when saving edited card: \(error.localizedDescription)",
                type: .error
            )
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Card Name", text: $cardName)
                        .onChange(of: cardName) {
                            showNameEmptyWarning = false
                        }
                } header: {
                    Text("Nickname for the card")
                } footer: {
                    if showNameEmptyWarning {
                        Text("Please enter a name for the card.")
                            .foregroundStyle(.red)
                    }
                }
                
                Section {
                    Picker("Card Type", selection: $cardType) {
                        Text("Debit").tag(CardType.debit)
                        Text("Credit").tag(CardType.credit)
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
                        Picker("Payment Network", selection: $paymentNetwork) {
                            Text("VISA").tag(CardPaymentNetwork.visa)
                            Text("Mastercard").tag(CardPaymentNetwork.mastercard)
                            Text("American Express").tag(CardPaymentNetwork.amex)
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
                    Text("Last four digits of the card")
                } footer: {
                    if showLastFourDigitsEmptyWarning {
                        Text("Please enter the last four digits of the card.")
                            .foregroundStyle(.red)
                    } else {
                        Text("For identifying purpose only.")
                    }
                }
                
                if cardType == .credit {
                    Section {
                        Picker("Card Perk Type", selection: $cardPerkType) {
                            Text("Reward Points")
                                .tag(CardPerkType.points)
                            Text("Cash Back")
                                .tag(CardPerkType.cashback)
                        }
                        .onChange(of: cardPerkType) {
                            if cardPerkType != card.perkType && !perksOnCard.isEmpty {
                                showPerkResetAlert = true
                            }
                        }
                    }
                    .alert("Card Perk", isPresented: $showPerkResetAlert) {
                        Button("Don't Proceed", role: .cancel) {
                            if let perkType = card.perkType {
                                cardPerkType = perkType
                            }
                            showPerkResetAlert = false
                        }
                        Button("Proceed", role: .destructive) {
                            removeAllPerksOnCard()
                            showPerkResetAlert = false
                        }
                    } message: {
                        Text("Changing perk type will clear all perks on this card.")
                    }
                    
                    Section {
                        ForEach(perksOnCard) { perk in
                            HStack {
                                CategoryLogoView(category: perk.category)
                                    .padding(.trailing, 5)
                                Text(perk.category?.name ?? "Everything")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("\(formattedRewardMultiplier(perk.perkType, perk.value))  \(perk.perkType.rawValue)")
                            }
                        }
                        .onDelete(perform: deletePerk)
                    } header: {
                        Text("Perks on This card")
                    } footer: {
                        if perksOnCard.isEmpty {
                            Text("This card doesn't have any perks registered.")
                        }
                    }
                    
                    AddPerkView(
                        expanded: $addPerkExpanded,
                        value: $addPerkValue,
                        category: $addPerkCategory,
                        valueFieldFocused: $addPerkValueFieldFocused,
                        perkType: cardPerkType
                    ) { addCardPerk() }
                }
            }
            .navigationTitle("Edit Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { save() }
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
                            Text("Done")
                                .bold()
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
