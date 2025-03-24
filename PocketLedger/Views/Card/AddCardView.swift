//
//  AddCardView.swift
//  PocketLedger
//
//  Created by Jiaming Guo on 2025-03-03.
//

import SwiftUI

struct AddCardView: View {
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
    
    @FocusState private var nameFieldIsFocused: Bool
    @FocusState private var lastFourDigitsFieldIsFocused: Bool
    
    func save() {
        if cardName.isEmpty {
            showNameEmptyWarning = true
        }
        if lastFourDigits.isEmpty || lastFourDigits.count != 4 {
            showLastFourDigitsEmptyWarning = true
        }
        guard !showNameEmptyWarning && !showLastFourDigitsEmptyWarning else { return }
        if cardType == .debit {
            let newCard = Card(
                name: cardName,
                cardType: cardType,
                paymentNetwork: paymentNetwork,
                lastFourDigits: lastFourDigits
            )
            modelContext.insert(newCard)
        } else if cardType == .credit {
            let newCard = Card(
                name: cardName,
                cardType: cardType,
                paymentNetwork: paymentNetwork,
                lastFourDigits: lastFourDigits,
                perkType: cardPerkType
            )
            modelContext.insert(newCard)
        }
        do {
            try modelContext.save()
            messageService.create(
                message: "Card added successfully!",
                type: .success
            )
        } catch {
            messageService.create(
                message: "Encountered error when saving new card: \(error.localizedDescription)",
                type: .error
            )
        }
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(String(localized: "Card Name", table: "AddEditCard"), text: $cardName)
                        .focused($nameFieldIsFocused)
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
                    Picker(String(localized: "Card Type", table:"AddEditCard"), selection: $cardType) {
                        Text(String(localized: "Debit", table: "AddEditCard")).tag(CardType.debit)
                        Text(String(localized: "Credit", table:"AddEditCard")).tag(CardType.credit)
                    }
                    .onChange(of: cardType) {
                        if cardType == .debit {
                            paymentNetwork = .interac
                        } else if cardType == .credit {
                            paymentNetwork = .visa
                        }
                    }
                    
                    if cardType == .credit {
                        Picker(String(localized: "Payment Network", table: "AddEditCard"), selection: $paymentNetwork) {
                            Text(String(localized: "VISA", table: "AddEditCard")).tag(CardPaymentNetwork.visa)
                            Text(String(localized: "Mastercard", table:"AddEditCard")).tag(CardPaymentNetwork.mastercard)
                            Text(String(localized: "American Express", table: "AddEditCard")).tag(CardPaymentNetwork.amex)
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
                            Text(String(localized: "Reward Points", table: "AddEditCard"))
                                .tag(CardPerkType.points)
                            Text(String(localized: "Cashback", table: "AddEditCard"))
                                .tag(CardPerkType.cashback)
                        }
                    } footer: {
                        Text(String(localized: "You can add card perks later in the edit page.", table: "AddEditCard"))
                    }
                }
            }
            .navigationTitle(String(localized: "Add a New Card", table:"AddEditCard"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save", table: "Common")) {
                        save()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel", table: "Common")) {
                        dismiss()
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
                            Text(String(localized: "Done", table: "Common")).bold()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    AddCardView()
}
