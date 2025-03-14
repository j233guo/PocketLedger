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
    
    let perkType: CardPerkType
    let addAction: () -> Void
    
    var body: some View {
        Section {
            if expanded {
                Picker("\(perkType.rawValue) Multiplier", selection: $value) {
                    ForEach(Array(stride(from: 0.25, through: 6, by: 0.25)), id: \.self) { number in
                        Text(formattedRewardMultiplier(perkType, number))
                    }
                }
                CategoryPickerView(selectedCategory: $category, transactionType: .expense, nameId: .cardperk)
                Button {
                    addAction()
                    withAnimation {
                        expanded = false
                    }
                } label: {
                    Text("Add")
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                }
            } else {
                Button {
                    expanded = true
                } label: {
                    Text("Add a New Perk")
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct EditCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var cardName = ""
    @State private var cardType: CardType = .debit
    @State private var paymentNetwork: CardPaymentNetwork = .interac
    @State private var lastFourDigits: String = ""
    @State private var cardPerkType: CardPerkType = .points
    
    @State private var showNameEmptyWarning = false
    @State private var showLastFourDigitsEmptyWarning = false
    
    @State private var addPerkExpanded = false
    @State private var addPerkValue: Double = 1.0
    @State private var addPerkCategory: TransactionCategory? = nil
    
    @FocusState private var nameFieldIsFocused: Bool
    @FocusState private var lastFourDigitsFieldIsFocused: Bool
    
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
    
    func addCardPerk() {
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
            card.perks = []
        }
        do {
            try modelContext.save()
        } catch {
            // TODO: replace with interactive alert banner
            print("Save failed when editing card: \(error.localizedDescription)")
        }
        dismiss()
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
                    }
                    
                    Section {
                        ForEach(perksOnCard) { perk in
                            let categoryName = perk.category?.name ?? "Everything"
                            Text("\(formattedRewardMultiplier(perk.perkType, perk.value)) \(perk.perkType.rawValue) on \(categoryName)")
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
                        perkType: cardPerkType
                    ) {
                        addCardPerk()
                    }
                }
            }
            .navigationTitle("Edit Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        save()
                    }
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
